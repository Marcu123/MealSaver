package com.marcu.mealsaver.Mapper;

import com.marcu.mealsaver.Dto.UserDTO;
import com.marcu.mealsaver.Model.User;
import org.mapstruct.Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class UserMapper {

    private final FoodMapper foodMapper;

    @Autowired
    public UserMapper(FoodMapper foodMapper) {
        this.foodMapper = foodMapper;
    }

   public UserDTO toDTO(User user){
        UserDTO userDTO = new UserDTO();
        userDTO.setId(user.getId());
        userDTO.setFirstName(user.getFirstName());
        userDTO.setLastName(user.getLastName());
        userDTO.setEmail(user.getEmail());
        userDTO.setUsername(user.getUsername());
        userDTO.setPassword(user.getPassword());
        userDTO.setCreatedAt(user.getCreatedAt());
        userDTO.setUpdatedAt(user.getUpdatedAt());
        userDTO.setFoods(user.getFoods() != null ? user.getFoods().stream()
                .map(foodMapper::toDTO)
                .collect(Collectors.toList())
                : null);
        return userDTO;
    }

    public User toEntity(UserDTO userDTO) {
        User user = new User();
        user.setId(userDTO.getId());
        user.setFirstName(userDTO.getFirstName());
        user.setLastName(userDTO.getLastName());
        user.setEmail(userDTO.getEmail());
        user.setUsername(userDTO.getUsername());
        user.setPassword(userDTO.getPassword());
        user.setCreatedAt(userDTO.getCreatedAt());
        user.setUpdatedAt(userDTO.getUpdatedAt());
        user.setFoods(userDTO.getFoods() != null ? userDTO.getFoods().stream()
                .map(foodMapper::toEntity)
                .collect(Collectors.toList())
                : null);
        return user;
    }
}