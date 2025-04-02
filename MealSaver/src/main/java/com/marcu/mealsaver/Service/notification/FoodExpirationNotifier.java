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
        Date now = new Date();
        List<Food> allFoods = foodRepository.findAll();

        for (Food food : allFoods) {
            String username = food.getUser().getUsername();
            Date expiration = food.getExpirationDate();

            long millisDiff = expiration.getTime() - now.getTime();
            long daysLeft = millisDiff / (1000 * 60 * 60 * 24);

            if (expiration.before(now)) {
                messagingTemplate.convertAndSendToUser(
                        username, "/queue/expired",
                        "⚠️ " + food.getName() + " is expired!"
                );
            } else if (daysLeft <= 3) {
                String message;
                if (daysLeft == 0) {
                    message = "⏳ " + food.getName() + " expires today!";
                } else if (daysLeft == 1) {
                    message = "⏳ " + food.getName() + " expires tomorrow!";
                } else {
                    message = "⏳ " + food.getName() + " expires in " + daysLeft + " days!";
                }

                messagingTemplate.convertAndSendToUser(
                        username, "/queue/expiring", message
                );
            }
        }
    }


}
