package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.RecipeVideoDTO;
import com.marcu.mealsaver.Service.RecipeVideoService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chef-battle")
public class RecipeVideoController {

    private final RecipeVideoService service;

    @Autowired
    public RecipeVideoController(RecipeVideoService service) {
        this.service = service;
    }

    @PostMapping("/upload")
    public ResponseEntity<RecipeVideoDTO> upload(
            @Valid @RequestBody RecipeVideoDTO dto,
            @AuthenticationPrincipal UserDetails user
    ) {
        return ResponseEntity.ok(service.uploadVideo(dto, user.getUsername()));
    }

    @GetMapping("/all")
    public ResponseEntity<List<RecipeVideoDTO>> getAll(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(service.getAllVideos(userDetails.getUsername()));
    }

    @GetMapping("/random")
    public ResponseEntity<List<RecipeVideoDTO>> getRandom(
            @RequestParam(defaultValue = "10") int count,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(service.getRandomVideos(count, userDetails.getUsername()));
    }

    @GetMapping("/tags")
    public ResponseEntity<List<RecipeVideoDTO>> filterByTags(
            @RequestParam List<String> tags,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(service.filterByTags(tags, userDetails.getUsername()));
    }

    @PostMapping("/{id}/like")
    public ResponseEntity<RecipeVideoDTO> likeVideo(@PathVariable Long id, @AuthenticationPrincipal UserDetails userDetails) {
        RecipeVideoDTO dto = service.likeVideo(id, userDetails.getUsername());
        return ResponseEntity.ok(dto);
    }



    @GetMapping("/{id}")
    public ResponseEntity<RecipeVideoDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getVideoById(id));
    }

    @GetMapping("/by-user/{username}")
    public ResponseEntity<List<RecipeVideoDTO>> getByUser(@PathVariable String username) {
        return ResponseEntity.ok(service.getVideosByUsername(username));
    }

    @GetMapping("/my-videos")
    public ResponseEntity<List<RecipeVideoDTO>> getMyVideos(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(service.getVideosByUsername(userDetails.getUsername()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVideo(@PathVariable Long id, @AuthenticationPrincipal UserDetails userDetails) {
        service.deleteVideo(id, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<RecipeVideoDTO> updateVideo(
            @PathVariable Long id,
            @Valid @RequestBody RecipeVideoDTO updatedDto,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(service.updateVideo(id, updatedDto, userDetails.getUsername()));
    }

    @PostMapping("/{id}/unlike")
    public ResponseEntity<?> unlikeVideo(@PathVariable Long id, @AuthenticationPrincipal UserDetails userDetails) {
        service.unlikeVideo(id, userDetails.getUsername());
        return ResponseEntity.ok("Video unliked");
    }

    @GetMapping("/liked")
    public ResponseEntity<List<RecipeVideoDTO>> getLikedVideos(@AuthenticationPrincipal UserDetails userDetails) {
        List<RecipeVideoDTO> likedVideos = service.getLikedVideosByUsername(userDetails.getUsername());
        return ResponseEntity.ok(likedVideos);
    }



}