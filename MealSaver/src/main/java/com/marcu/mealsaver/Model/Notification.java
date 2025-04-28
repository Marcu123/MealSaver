package com.marcu.mealsaver.Model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Entity
@Getter
@Setter
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String message;
    private Date createdAt;
    private boolean read;

    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonIgnore
    private User user;

    public Notification() {
    }

    public Notification(String message, Date createdAt, boolean read, User user) {
        this.message = message;
        this.createdAt = createdAt;
        this.read = read;
        this.user = user;
    }
}
