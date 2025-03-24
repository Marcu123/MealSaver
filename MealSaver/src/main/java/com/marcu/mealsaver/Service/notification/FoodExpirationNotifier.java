package com.marcu.mealsaver.Service.notification;

import com.marcu.mealsaver.Model.Food;
import com.marcu.mealsaver.Repository.FoodRepository;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.List;

@Component
public class FoodExpirationNotifier {
    private final FoodRepository foodRepository;
    private final SimpMessagingTemplate messagingTemplate;

    public FoodExpirationNotifier(FoodRepository foodRepository, SimpMessagingTemplate messagingTemplate) {
        this.foodRepository = foodRepository;
        this.messagingTemplate = messagingTemplate;
    }

    @Scheduled(fixedRate = 60000)
    public void checkExpiringFoods() {
        List<Food> expired = foodRepository.findAll().stream()
                .filter(f -> f.getExpirationDate().before(new Date()))
                .toList();

        for (Food food : expired) {
            String username = food.getUser().getUsername();
            System.out.println("Trimit notificare pentru: " + food.getUser().getUsername() + " pentru alimentul: " + food.getName());
            messagingTemplate.convertAndSendToUser(username, "/queue/expired", "⚠️ " + food.getName() + " expired!");
        }


    }

}
