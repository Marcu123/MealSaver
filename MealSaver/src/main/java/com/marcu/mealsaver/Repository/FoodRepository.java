package com.marcu.mealsaver.Repository;

import com.marcu.mealsaver.Model.Food;
import com.marcu.mealsaver.Model.User;
import jakarta.validation.constraints.NotBlank;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FoodRepository extends JpaRepository<Food, Long> {
    Optional<Food> findById(Long foodId);
    Optional<Food> findByName(String name);
    Boolean existsByName(String name);

    List<Food> findAllByUser(User user);
}
