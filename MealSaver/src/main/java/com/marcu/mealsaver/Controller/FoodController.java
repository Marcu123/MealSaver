package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.FoodDTO;
import com.marcu.mealsaver.Dto.UserDTO;
import com.marcu.mealsaver.Service.FoodService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/foods")
public class FoodController {

    private final FoodService foodService;

    @Autowired
    public FoodController(FoodService foodService) {
        this.foodService = foodService;
    }

    @GetMapping("/all")
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

    @DeleteMapping("/{foodId}")
    public ResponseEntity<FoodDTO> deleteFood(@PathVariable Long foodId) {
        foodService.deleteFood(foodId);
        return ResponseEntity.noContent().build();
    }
}
