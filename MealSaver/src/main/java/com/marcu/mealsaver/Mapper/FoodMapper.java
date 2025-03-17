package com.marcu.mealsaver.Mapper;

import com.marcu.mealsaver.Dto.FoodDTO;
import com.marcu.mealsaver.Model.Food;
import com.marcu.mealsaver.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class FoodMapper {

    private final UserRepository userRepository;

    @Autowired
    public FoodMapper(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public FoodDTO toDTO(Food food) {
        return new FoodDTO(
                food.getId(),
                food.getName(),
                food.getSize(),
                food.getExpirationDate(),
                food.getUser().getUsername()
        );
    }

    public Food toEntity(FoodDTO foodDTO) {
        Food food = new Food();
        food.setId(foodDTO.getId());
        food.setName(foodDTO.getName());
        food.setSize(foodDTO.getSize());
        food.setExpirationDate(foodDTO.getExpirationDate());
        food.setUser(userRepository.findByUsername(foodDTO.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found")));

        return food;
    }

    public Iterable<FoodDTO> toDTOs(List<Food> foods) {
        return foods.stream()
                .map(this::toDTO)
                .toList();
    }
}
