package com.marcu.mealsaver.Service.notification;

import com.marcu.mealsaver.Model.Food;
import com.marcu.mealsaver.Repository.FoodRepository;
import com.marcu.mealsaver.Service.NotificationService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

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
        Date today = truncateToDay(new Date());
        List<Food> allFoods = foodRepository.findAll();

        for (Food food : allFoods) {
            String username = food.getUser().getUsername();
            Date expiration = truncateToDay(food.getExpirationDate());

            long millisDiff = expiration.getTime() - today.getTime();
            long daysLeft = millisDiff / (1000 * 60 * 60 * 24);

            if (daysLeft < 0) {
                notificationService.sendAndSave(
                        username,
                        food.getName() + " is expired!",
                        "/queue/expired"
                );
            } else if (daysLeft <= 3) {
                // Aproape expirat
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

    private Date truncateToDay(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }
}
