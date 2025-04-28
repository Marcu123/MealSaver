package com.marcu.mealsaver.Service.notification;

import com.marcu.mealsaver.Model.Food;
import com.marcu.mealsaver.Repository.FoodRepository;
import com.marcu.mealsaver.Service.NotificationService;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.List;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

@Component
public class FoodExpirationNotifier {

    private final FoodRepository foodRepository;
    private final NotificationService notificationService;

    public FoodExpirationNotifier(FoodRepository foodRepository,
                                  NotificationService notificationService) {
        this.foodRepository = foodRepository;
        this.notificationService = notificationService;
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
                notificationService.sendAndSave(
                        username,
                        food.getName() + " is expired!",
                        "/queue/expired"
                );
            } else if (daysLeft <= 3) {
                String message = switch ((int) daysLeft) {
                    case 0 -> food.getName() + " expires today!";
                    case 1 -> food.getName() + " expires tomorrow!";
                    default -> food.getName() + " expires in " + daysLeft + " days!";
                };

                notificationService.sendAndSave(
                        username,
                        message,
                        "/queue/expiring"
                );
            }
        }
    }
}



