package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.RecipeDTO;
import com.marcu.mealsaver.Service.RecipeService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/api/recipes")
@CrossOrigin(origins = "*")
public class RecipeController {

    private final RecipeService recipeService;

    public RecipeController(RecipeService recipeService) {
        this.recipeService = recipeService;
    }

    @GetMapping("/filter")
    public List<RecipeDTO> filterRecipes(
            @RequestParam(required = false) List<String> ingredients,
            @RequestParam(required = false) List<String> category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size
    ) {
        return recipeService.getRecipes(ingredients, category, page, size);
    }

    @GetMapping("/categories")
    public Set<String> getAllCategories() {
        return recipeService.getAllCategories();
    }
}
