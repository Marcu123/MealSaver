package com.marcu.mealsaver.Service;

import com.marcu.mealsaver.Dto.FoodDTO;
import com.marcu.mealsaver.Mapper.FoodMapper;
import com.marcu.mealsaver.Model.Food;
import com.marcu.mealsaver.Model.User;
import com.marcu.mealsaver.Repository.FoodRepository;
import com.marcu.mealsaver.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


@Service
public class FoodService {

    private final FoodRepository foodRepository;
    private final FoodMapper foodMapper;
    private final UserRepository userRepository;

    @Autowired
    public FoodService(FoodRepository foodRepository, FoodMapper foodMapper, UserRepository userRepository) {
        this.foodRepository = foodRepository;
        this.foodMapper = foodMapper;
        this.userRepository = userRepository;
    }

    public FoodDTO addFood(FoodDTO foodDTO) {
        foodRepository.findByName(foodDTO.getName())
                .ifPresent(food -> {
                    throw new RuntimeException("Food already exists");
                });

        userRepository.findByUsername(foodDTO.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Food food = foodMapper.toEntity(foodDTO);
        foodRepository.save(food);
        return foodMapper.toDTO(food);
    }

    public void updateFood(String name, FoodDTO foodDTO) {
        foodRepository.findByName(name).orElseThrow(() -> new RuntimeException("Food not found"));
        Food food = foodMapper.toEntity(foodDTO);
        foodRepository.save(food);
    }

    public void deleteFood(Long foodId) {
        Food food = foodRepository.findById(foodId).orElseThrow(() -> new RuntimeException("Food not found"));
        foodRepository.delete(food);
    }

    public Iterable<FoodDTO> getAllFoods() {
        return foodMapper.toDTOs(foodRepository.findAll());
    }

    public FoodDTO getFoodByName(String name) {
        Food food = foodRepository.findByName(name).orElseThrow(() -> new RuntimeException("Food not found"));
        return foodMapper.toDTO(food);
    }
}
