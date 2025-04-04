package com.marcu.mealsaver.Service;

import com.marcu.mealsaver.Dto.FoodDTO;
import com.marcu.mealsaver.Exception.FoodAlreadyExistsException;
import com.marcu.mealsaver.Exception.FoodNotFoundException;
import com.marcu.mealsaver.Exception.UserNotFoundException;
import com.marcu.mealsaver.Mapper.FoodMapper;
import com.marcu.mealsaver.Model.Food;
import com.marcu.mealsaver.Model.User;
import com.marcu.mealsaver.Repository.FoodRepository;
import com.marcu.mealsaver.Repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;


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
                    throw new FoodAlreadyExistsException("Food already exists: " + foodDTO.getName());
                });

        userRepository.findByUsername(foodDTO.getUsername())
                .orElseThrow(() -> new UserNotFoundException("User not found: " + foodDTO.getUsername()));

        Food food = foodMapper.toEntity(foodDTO);
        foodRepository.save(food);
        return foodMapper.toDTO(food);
    }

    public void updateFood(String name, FoodDTO foodDTO) {
        foodRepository.findByName(name).orElseThrow(() -> new FoodNotFoundException("Food not found: " + name));
        Food food = foodMapper.toEntity(foodDTO);
        foodRepository.save(food);
    }

    public void deleteFood(Long foodId) {
        Food food = foodRepository.findById(foodId).orElseThrow(() -> new FoodNotFoundException("The id of the food not found: " + foodId));
        foodRepository.delete(food);
    }

    public Iterable<FoodDTO> getAllFoods() {
        return foodMapper.toDTOs(foodRepository.findAll());
    }

    public FoodDTO getFoodByName(String name) {
        Food food = foodRepository.findByName(name).orElseThrow(() -> new FoodNotFoundException("Food not found: " + name));
        return foodMapper.toDTO(food);
    }

    public Iterable<FoodDTO> getMyFoods(String username) {
        User user = userRepository.findByUsername(username).orElseThrow(() -> new UserNotFoundException("User not found: " + username));
        return foodMapper.toDTOs(foodRepository.findAllByUser(user));
    }

    public List<FoodDTO> getExpiringSoon(String username) {
        User user = userRepository.findByUsername(username).orElseThrow(() -> new UserNotFoundException("User not found: " + username));
        List<Food> allFoods = foodRepository.findAllByUser(user);
        long now = System.currentTimeMillis();

        return allFoods.stream()
                .filter(f -> (f.getExpirationDate().getTime() - now) <= 3L * 24 * 60 * 60 * 1000)
                .map(foodMapper::toDTO)
                .toList();
    }

    public List<FoodDTO> getExpired(String username) {
        User user = userRepository.findByUsername(username).orElseThrow(() -> new UserNotFoundException("User not found: " + username));
        List<Food> allFoods = foodRepository.findAllByUser(user);
        long now = System.currentTimeMillis();

        return allFoods.stream()
                .filter(f -> f.getExpirationDate().getTime() < now)
                .map(foodMapper::toDTO)
                .toList();
    }
}
