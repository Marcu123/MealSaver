package com.marcu.mealsaver.Mapper;

import com.marcu.mealsaver.Dto.RecipeVideoDTO;
import com.marcu.mealsaver.Model.RecipeVideo;
import org.springframework.stereotype.Component;

@Component
public class RecipeVideoMapper {

    public RecipeVideoDTO toDTO(RecipeVideo video) {
        RecipeVideoDTO dto = new RecipeVideoDTO(
                video.getId(),
                video.getVideoUrl(),
                video.getTags(),
                video.getDescription(),
                video.getThumbnailUrl(),
                video.getCreatedAt(),
                video.getLikes(),
                video.getUser().getUsername(),
                false
        );
        return dto;
    }

    public RecipeVideo toEntity(RecipeVideoDTO dto) {
        RecipeVideo video = new RecipeVideo();
        video.setId(dto.getId());
        video.setVideoUrl(dto.getVideoUrl());
        video.setTags(dto.getTags());
        video.setDescription(dto.getDescription());
        video.setThumbnailUrl(dto.getThumbnailUrl());
        video.setCreatedAt(dto.getCreatedAt());
        video.setLikes(dto.getLikes());
        return video;
    }
}