package com.marcu.mealsaver.Service;

import com.marcu.mealsaver.Dto.RecipeVideoDTO;
import com.marcu.mealsaver.Mapper.RecipeVideoMapper;
import com.marcu.mealsaver.Model.RecipeVideo;
import com.marcu.mealsaver.Model.User;
import com.marcu.mealsaver.Repository.RecipeVideoRepository;
import com.marcu.mealsaver.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecipeVideoService {

    private final RecipeVideoRepository videoRepo;
    private final UserRepository userRepo;
    private final RecipeVideoMapper mapper;

    @Autowired
    public RecipeVideoService(RecipeVideoRepository videoRepo, UserRepository userRepo, RecipeVideoMapper mapper) {
        this.videoRepo = videoRepo;
        this.userRepo = userRepo;
        this.mapper = mapper;
    }

    public RecipeVideoDTO uploadVideo(RecipeVideoDTO dto, String username) {
        User user = userRepo.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username));
        RecipeVideo entity = mapper.toEntity(dto);
        entity.setUser(user);
        RecipeVideo saved = videoRepo.save(entity);
        return mapper.toDTO(saved);
    }

    public List<RecipeVideoDTO> getAllVideos(String username) {
        User currentUser = userRepo.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return videoRepo.findAll().stream()
                .sorted(Comparator.comparing(RecipeVideo::getCreatedAt).reversed())
                .map(video -> {
                    RecipeVideoDTO dto = mapper.toDTO(video);
                    dto.setLikedByUser(video.getLikedBy().contains(currentUser));
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public List<RecipeVideoDTO> getRandomVideos(int count, String username) {
        User currentUser = userRepo.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        List<RecipeVideo> all = videoRepo.findAll();
        Collections.shuffle(all);
        return all.stream()
                .limit(count)
                .map(video -> {
                    RecipeVideoDTO dto = mapper.toDTO(video);
                    dto.setLikedByUser(video.getLikedBy().contains(currentUser));
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public List<RecipeVideoDTO> filterByTags(List<String> tags, String username) {
        User currentUser = userRepo.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return videoRepo.findAll().stream()
                .filter(video -> video.getTags().stream()
                        .anyMatch(tag -> tags.stream()
                                .anyMatch(input -> tag.toLowerCase().contains(input.toLowerCase()))))


                .map(video -> {
                    RecipeVideoDTO dto = mapper.toDTO(video);
                    dto.setLikedByUser(video.getLikedBy().contains(currentUser));
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public RecipeVideoDTO likeVideo(Long id, String username) {
        RecipeVideo video = videoRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Video not found"));

        User user = userRepo.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!video.getLikedBy().contains(user)) {
            video.getLikedBy().add(user);
            video.setLikes(video.getLikes() + 1);
            videoRepo.save(video);
        }

        RecipeVideoDTO dto = mapper.toDTO(video);
        dto.setLikedByUser(true);
        return dto;
    }


    public RecipeVideoDTO getVideoById(Long id) {
        RecipeVideo video = videoRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Video not found"));
        return mapper.toDTO(video);
    }

    public List<RecipeVideoDTO> getVideosByUsername(String username) {
        User user = userRepo.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return user.getRecipeVideos() != null ?
                user.getRecipeVideos().stream().map(video -> {
                    RecipeVideoDTO dto = mapper.toDTO(video);
                    dto.setLikedByUser(video.getLikedBy().contains(user));
                    return dto;
                }).collect(Collectors.toList())
                : Collections.emptyList();
    }

    public void deleteVideo(Long id, String username) {
        RecipeVideo video = videoRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Video not found"));

        if (!video.getUser().getUsername().equals(username)) {
            throw new SecurityException("Unauthorized to delete this video.");
        }

        videoRepo.delete(video);
    }

    public RecipeVideoDTO updateVideo(Long id, RecipeVideoDTO updatedDto, String username) {
        RecipeVideo video = videoRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Video not found"));

        if (!video.getUser().getUsername().equals(username)) {
            throw new SecurityException("Unauthorized to edit this video.");
        }

        video.setDescription(updatedDto.getDescription());
        video.setTags(updatedDto.getTags());
        video.setThumbnailUrl(updatedDto.getThumbnailUrl());
        return mapper.toDTO(videoRepo.save(video));
    }

    public void unlikeVideo(Long videoId, String username) {
        RecipeVideo video = videoRepo.findById(videoId)
                .orElseThrow(() -> new RuntimeException("Video not found"));

        User user = userRepo.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (video.getLikedBy().contains(user)) {
            video.getLikedBy().remove(user);
            video.setLikes(Math.max(0, video.getLikes() - 1));
            videoRepo.save(video);
        }
    }

    public List<RecipeVideoDTO> getLikedVideosByUsername(String username) {
        User user = userRepo.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<RecipeVideo> likedVideos = videoRepo.findAll()
                .stream()
                .filter(video -> video.getLikedBy().contains(user))
                .collect(Collectors.toList());

        return likedVideos.stream().map(video -> {
            RecipeVideoDTO dto = mapper.toDTO(video);
            dto.setLikedByUser(true);
            return dto;
        }).collect(Collectors.toList());
    }

}
