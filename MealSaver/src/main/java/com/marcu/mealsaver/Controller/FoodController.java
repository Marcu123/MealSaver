package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.FoodDTO;
import com.marcu.mealsaver.Dto.UserDTO;
import com.marcu.mealsaver.Service.FoodService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/foods")
@SecurityRequirement(name = "bearerAuth")
public class FoodController {

    private final FoodService foodService;

    @Autowired
    public FoodController(FoodService foodService) {
        this.foodService = foodService;
    }

    @GetMapping
    public ResponseEntity<Iterable<FoodDTO>> getAllFoods() {
        return ResponseEntity.ok(foodService.getAllFoods());
    }

    @GetMapping("/{name}")
    public ResponseEntity<FoodDTO> getFoodByName(@PathVariable String name) {
        return ResponseEntity.ok(foodService.getFoodByName(name));
    }

    @PostMapping
    public ResponseEntity<FoodDTO> addFood(@RequestBody FoodDTO foodDTO) {
        return ResponseEntity.status(HttpStatus.CREATED).body(foodService.addFood(foodDTO));
    }

    @PutMapping("/{name}")
    public ResponseEntity<Void> updateFood(@PathVariable String name, @RequestBody FoodDTO foodDTO) {
        foodService.updateFood(name, foodDTO);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/my")
    public ResponseEntity<Iterable<FoodDTO>> getMyFoods(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(foodService.getMyFoods(userDetails.getUsername()));
    }
    @DeleteMapping("/{foodId}")
    public ResponseEntity<FoodDTO> deleteFood(@PathVariable Long foodId) {
        foodService.deleteFood(foodId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/expiring-soon")
    public List<FoodDTO> getExpiringSoon(@AuthenticationPrincipal UserDetails user) {
        return foodService.getExpiringSoon(user.getUsername());
    }

    @GetMapping("/expired")
    public List<FoodDTO> getExpired(@AuthenticationPrincipal UserDetails user) {
        return foodService.getExpired(user.getUsername());
    }



}
