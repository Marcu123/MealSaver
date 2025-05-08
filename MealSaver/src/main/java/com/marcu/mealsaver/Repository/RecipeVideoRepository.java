package com.marcu.mealsaver.Repository;

import com.marcu.mealsaver.Model.RecipeVideo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RecipeVideoRepository extends JpaRepository<RecipeVideo, Long> {
}