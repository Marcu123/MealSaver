package com.marcu.mealsaver.Service;

import com.marcu.mealsaver.Dto.RecipeDTO;
import jakarta.annotation.PostConstruct;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.springframework.stereotype.Service;

import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
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
            var parser = CSVFormat.DEFAULT
                    .withFirstRecordAsHeader()
                    .parse(new InputStreamReader(stream, StandardCharsets.UTF_8));

            for (CSVRecord record : parser) {
                String title = fixCorruptedCharacters(record.get("Title"));
                String instructions = fixCorruptedCharacters(record.get("Instructions"));
                String imageName = fixCorruptedCharacters(record.get("Image_Name"));

                List<String> ingredients = parseAndFixList(record.get("Cleaned_Ingredients"));
                List<String> categories = parseAndFixList(record.get("Categories"));
                String source = "Food Ingredients and Recipe Dataset with Images";

                allRecipes.add(new RecipeDTO(title, ingredients, instructions, categories, imageName, Collections.singletonList(source)));
            }
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

                        System.out.println("➡ Categories in recipe: " + recipeCategories);
                        System.out.println("➡ Categories selected: " + categories);

                        boolean allMatch = categories.stream()
                                .filter(Objects::nonNull)
                                .map(c -> c.toLowerCase().trim())
                                .allMatch(filterCat ->
                                        recipeCategories.stream().anyMatch(recipeCat ->
                                                recipeCat.equalsIgnoreCase(filterCat)
                                        )
                                );

                        if (!allMatch) {
                            return false;
                        }
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

                        if (!anyMatch) {
                            return false;
                        }
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

    private List<String> parseAndFixList(String input) {
        if (input == null) return Collections.emptyList();
        input = input.replaceAll("^\\[|]$", "").trim();
        if (input.isEmpty()) return Collections.emptyList();
        return Arrays.stream(input.split(","))
                .map(s -> fixCorruptedCharacters(s.replaceAll("'", "").trim()))
                .collect(Collectors.toList());
    }

    private String fixCorruptedCharacters(String input) {
        if (input == null) return "";
        return input
                .replace("Â½", "½")
                .replace("Â¾", "¾")
                .replace("Â¼", "¼")
                .replace("â€“", "–")
                .replace("â€”", "—")
                .replace("â€™", "’")
                .replace("â€œ", "“")
                .replace("â€", "”")
                .replace("â€˜", "‘")
                .replace("â€¦", "…")
                .replace("Ã", "")
                .replace("Â", "")
                .trim();
    }
}
