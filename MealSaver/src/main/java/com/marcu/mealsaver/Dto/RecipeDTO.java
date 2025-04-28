package com.marcu.mealsaver.Dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeDTO {
    private String title;
    private List<String> cleanedIngredients;
    private String instructions;
    private List<String> categories;
    private String imageName;
}
