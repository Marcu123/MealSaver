package com.marcu.mealsaver.Dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeResponseDTO {
    private String title;
    private List<String> ingredients;
    private List<String> steps;
    private List<String> optionalIngredientsToBuy;
    private String imageUrl;
    private List<String> sources;
}

