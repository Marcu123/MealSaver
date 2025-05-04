package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.RecipeResponseDTO;
import com.marcu.mealsaver.Service.RecipeGeneratorService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/ai")
public class AiRecipeController {

    private final RecipeGeneratorService recipeGeneratorService;

    public AiRecipeController(RecipeGeneratorService recipeGeneratorService) {
        this.recipeGeneratorService = recipeGeneratorService;
    }

    @GetMapping("/recipes")
    public ResponseEntity<List<RecipeResponseDTO>> generatePersonalRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size
    ) {
        System.out.println("Generating recipe for user: " + userDetails.getUsername() + ", page: " + page + ", size: " + size);
        List<RecipeResponseDTO> recipes = recipeGeneratorService.generateRecipeForUser(userDetails.getUsername(), page, size);
        return ResponseEntity.ok(recipes);
    }
}
