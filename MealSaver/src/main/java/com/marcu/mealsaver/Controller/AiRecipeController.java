package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.RecipeResponseDTO;
import com.marcu.mealsaver.Service.RecipeGeneratorService;
import com.marcu.mealsaver.Dto.UserDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AiRecipeController {

    private final RecipeGeneratorService recipeGeneratorService;

    public AiRecipeController(RecipeGeneratorService recipeGeneratorService) {
        this.recipeGeneratorService = recipeGeneratorService;
    }

    @GetMapping("/recipes")
    public ResponseEntity<List<RecipeResponseDTO>> generatePersonalRecipe(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(recipeGeneratorService.generateRecipeForUser(userDetails.getUsername()));
    }


}
