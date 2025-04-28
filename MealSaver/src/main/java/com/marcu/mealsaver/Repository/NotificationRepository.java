package com.marcu.mealsaver.Repository;

import com.marcu.mealsaver.Model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUserUsernameOrderByCreatedAtDesc(String username);
    Long countByUserUsernameAndReadFalse(String username);
}

