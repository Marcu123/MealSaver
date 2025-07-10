package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.*;
import com.marcu.mealsaver.Service.FoodService;
import com.marcu.mealsaver.Service.RecipeVideoService;
import com.marcu.mealsaver.Service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UserService userService;
    private final FoodService foodService;
    private final RecipeVideoService recipeVideoService;

    public AdminController(UserService userService, FoodService foodService, RecipeVideoService recipeVideoService) {
        this.userService = userService;
        this.foodService = foodService;
        this.recipeVideoService = recipeVideoService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> loginUser(@Valid @RequestBody LoginRequestDTO loginRequestDTO) {
        LoginResponseDTO loginResponseDTO = userService.loginUser(loginRequestDTO);
        return ResponseEntity.ok(loginResponseDTO);
    }

    @GetMapping("/all")
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        List<UserDTO> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @GetMapping("/search")
    public ResponseEntity<List<UserDTO>> searchUsers(@RequestParam String usernamePart) {
        return ResponseEntity.ok(userService.searchByUsernameContains(usernamePart));
    }

    @GetMapping("/by-user/{username}/foods")
    public ResponseEntity<Iterable<FoodDTO>> getFoodsByUser(@PathVariable String username) {
        return ResponseEntity.ok(foodService.getFoodsByUser(username));
    }

    @GetMapping("/by-user/{username}/videos")
    public ResponseEntity<List<RecipeVideoDTO>> getVideosByUser(@PathVariable String username) {
        return ResponseEntity.ok(recipeVideoService.getVideosByUsername(username));
    }




}
