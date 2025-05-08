package com.marcu.mealsaver.Dto;

import lombok.*;

import java.util.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RecipeVideoDTO {
    private Long id;
    private String videoUrl;
    private List<String> tags;
    private String description;
    private String thumbnailUrl;
    private Date createdAt;
    private int likes;
    private String username;
    private boolean likedByUser;

}