package com.marcu.mealsaver.Service;

import com.marcu.mealsaver.Dto.RecipeDTO;
import jakarta.annotation.PostConstruct;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.springframework.stereotype.Service;

import java.io.InputStreamReader;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecipeService {

    private final List<RecipeDTO> allRecipes = new ArrayList<>();

    @PostConstruct
    public void loadCsv() {
        try {
            var stream = getClass().getResourceAsStream("/recipes.csv");
            assert stream != null;
            var parser = CSVFormat.DEFAULT.withFirstRecordAsHeader().parse(new InputStreamReader(stream));
            for (CSVRecord record : parser) {
                List<String> ingredients = parseList(record.get("Cleaned_Ingredients"));
                List<String> categories = parseList(record.get("Categories"));
                String imageName = record.get("Image_Name");

                allRecipes.add(new RecipeDTO(
                        record.get("Title"),
                        ingredients,
                        record.get("Instructions"),
                        categories,
                        imageName
                ));
            }
            System.out.println("✅ Loaded recipes: " + allRecipes.size());
        } catch (Exception e) {
            throw new RuntimeException("Could not read recipes", e);
        }
    }

    public List<RecipeDTO> getRecipes(List<String> ingredients, List<String> categories, int page, int size) {
        return allRecipes.stream()
                .filter(recipe -> {
                    if (categories != null && !categories.isEmpty()) {
                        List<String> recipeCategories = recipe.getCategories().stream()
                                .filter(Objects::nonNull)
                                .map(c -> c.toLowerCase().trim())
                                .toList();

                        boolean anyMatch = categories.stream()
                                .filter(Objects::nonNull)
                                .map(String::toLowerCase)
                                .anyMatch(filterCat ->
                                        recipeCategories.stream().anyMatch(recipeCat ->
                                                recipeCat.contains(filterCat) || filterCat.contains(recipeCat)
                                        )
                                );
                        if (!anyMatch) return false;
                    }

                    if (ingredients != null && !ingredients.isEmpty()) {
                        List<String> recipeIngredients = recipe.getCleanedIngredients().stream()
                                .filter(Objects::nonNull)
                                .map(i -> i.toLowerCase().trim())
                                .toList();

                        boolean anyMatch = ingredients.stream()
                                .filter(Objects::nonNull)
                                .map(String::toLowerCase)
                                .anyMatch(filterIng ->
                                        recipeIngredients.stream().anyMatch(recipeIng ->
                                                recipeIng.contains(filterIng) || filterIng.contains(recipeIng)
                                        )
                                );
                        if (!anyMatch) return false;
                    }

                    return true;
                })
                .skip((long) page * size)
                .limit(size)
                .collect(Collectors.toList());
    }


    public Set<String> getAllCategories() {
        return allRecipes.stream()
                .flatMap(r -> r.getCategories().stream())
                .map(String::toLowerCase)
                .collect(Collectors.toCollection(TreeSet::new));
    }

    private List<String> parseList(String input) {
        if (input == null) return Collections.emptyList();
        input = input.replaceAll("^\\[|]$", "").trim();
        if (input.isEmpty()) return Collections.emptyList();
        return Arrays.stream(input.split(","))
                .map(s -> s.replaceAll("'", "").trim().toLowerCase())
                .collect(Collectors.toList());
    }
}
