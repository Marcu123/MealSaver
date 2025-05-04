package com.marcu.mealsaver.Service;

import com.marcu.mealsaver.Dto.RecipeResponseDTO;
import com.marcu.mealsaver.Exception.UserNotFoundException;
import com.marcu.mealsaver.Model.Food;
import com.marcu.mealsaver.Model.User;
import com.marcu.mealsaver.Repository.FoodRepository;
import com.marcu.mealsaver.Repository.UserRepository;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Date;
import java.util.List;

@Service
public class RecipeGeneratorService {

    private final FoodRepository foodRepository;
    private final UserRepository userRepository;
    private final OpenAiServiceWrapper aiService;
    private final GoogleImageService imageService;
    private final RecipeService recipeService;

    public RecipeGeneratorService(FoodRepository foodRepository,
                                  UserRepository userRepository,
                                  OpenAiServiceWrapper aiService,
                                  GoogleImageService imageService,
                                  RecipeService recipeService) {
        this.foodRepository = foodRepository;
        this.userRepository = userRepository;
        this.aiService = aiService;
        this.imageService = imageService;
        this.recipeService = recipeService;
    }

    public List<RecipeResponseDTO> generateRecipeForUser(String username, int page, int size) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + username));

        List<Food> allFoods = foodRepository.findAllByUser(user);
        Date now = new Date();

        List<String> expiringFoods = allFoods.stream()
                .filter(f -> (f.getExpirationDate().getTime() - now.getTime()) <= 3L * 24 * 60 * 60 * 1000)
                .map(Food::getName)
                .toList();

        List<String> otherFoods = allFoods.stream()
                .filter(f -> !expiringFoods.contains(f.getName()))
                .map(Food::getName)
                .toList();

        if (expiringFoods.isEmpty() && otherFoods.isEmpty()) {
            System.out.println("No foods. Returning recipes from CSV dataset, page: " + page);
            return recipeService.getRecipes(Collections.emptyList(), Collections.emptyList(), page, size)
                    .stream()
                    .map(r -> new RecipeResponseDTO(
                            r.getTitle(),
                            r.getCleanedIngredients(),
                            List.of(r.getInstructions()),
                            r.getCategories(),
                            r.getImageName()
                    ))
                    .toList();
        }

        System.out.println("Generating AI recipes for page: " + page);

        String prompt;
        if (page == 0) {
            prompt = buildPrompt(expiringFoods, otherFoods);
        } else {
            prompt = buildContinuationPrompt(expiringFoods, otherFoods, page);
        }

        JSONArray recipesArray = aiService.generateJsonArrayResponse(prompt);

        return recipesArray.toList().stream()
                .map(obj -> {
                    JSONObject json = new JSONObject((java.util.Map<?, ?>) obj);
                    String imageUrl = imageService.findImageForTitle(json.getString("title"));

                    return new RecipeResponseDTO(
                            json.getString("title"),
                            json.getJSONArray("ingredients").toList().stream().map(Object::toString).toList(),
                            json.getJSONArray("steps").toList().stream().map(Object::toString).toList(),
                            json.getJSONArray("optionalIngredientsToBuy").toList().stream().map(Object::toString).toList(),
                            imageUrl
                    );
                })
                .toList();
    }



    private String buildPrompt(List<String> expiring, List<String> other) {
        return """
                You are a smart cooking assistant. Based on the following ingredients:
                
                - Expiring soon: %s
                - Available: %s
                
                Generate 5 creative and diverse recipes as a **strict JSON array of objects**. Each object must follow this structure:
                
                {
                  "title": "string",
                  "ingredients": ["ingredient1", "ingredient2", "..."],
                  "steps": ["Step 1...", "Step 2...", "..."],
                  "optionalIngredientsToBuy": ["optional1", "optional2", "..."]
                }
                
                ⚠️ Output only valid JSON (an array with 5 recipe objects). No explanations. No markdown. No text outside the array.
                """.formatted(String.join(", ", expiring), String.join(", ", other));
    }

    private String buildContinuationPrompt(List<String> expiring, List<String> other, int page) {
        return """
            You are a smart cooking assistant.
            
            Based on these ingredients:
            - Expiring soon: %s
            - Available: %s

            Generate 5 MORE creative and completely new recipes, DIFFERENT from any previous ones.
            Each recipe must follow STRICTLY this JSON format:

            {
              "title": "string",
              "ingredients": ["ingredient1", "ingredient2", "..."],
              "steps": ["Step 1...", "Step 2...", "..."],
              "optionalIngredientsToBuy": ["optional1", "optional2", "..."]
            }

            ⚠️ Output only valid JSON (no explanations, no extra text).

            This is continuation page %d.
            """.formatted(String.join(", ", expiring), String.join(", ", other), page);
    }


}