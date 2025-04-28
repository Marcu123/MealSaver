package com.marcu.mealsaver.Service;

import com.marcu.mealsaver.Model.Notification;
import com.marcu.mealsaver.Model.User;
import com.marcu.mealsaver.Repository.NotificationRepository;
import com.marcu.mealsaver.Repository.UserRepository;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final UserRepository userRepository;

    public NotificationService(NotificationRepository notificationRepository,
                               SimpMessagingTemplate messagingTemplate,
                               UserRepository userRepository) {
        this.notificationRepository = notificationRepository;
        this.messagingTemplate = messagingTemplate;
        this.userRepository = userRepository;
    }

    public List<Notification> getNotificationsForUser(String username) {
        return notificationRepository.findByUserUsernameOrderByCreatedAtDesc(username);
    }

    public void markAsRead(Long id) {
        Optional<Notification> notifOpt = notificationRepository.findById(id);
        notifOpt.ifPresent(n -> {
            n.setRead(true);
            notificationRepository.save(n);
        });
    }

    public void clearAll(String username) {
        List<Notification> notifications = notificationRepository.findByUserUsernameOrderByCreatedAtDesc(username);
        notificationRepository.deleteAll(notifications);
    }

    public boolean deleteById(Long id) {
        Optional<Notification> notifOpt = notificationRepository.findById(id);
        if (notifOpt.isPresent()) {
            notificationRepository.delete(notifOpt.get());
            return true;
        }
        return false;
    }

    public void sendAndSave(String username, String message, String topic) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Notification notification = new Notification();
        notification.setUser(user);
        notification.setMessage(message);
        notification.setRead(false);
        notification.setCreatedAt(new Date());

        notificationRepository.save(notification);
        messagingTemplate.convertAndSendToUser(username, topic, message);
    }
}
