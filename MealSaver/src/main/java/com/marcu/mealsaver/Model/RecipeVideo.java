package com.marcu.mealsaver.Model;

import jakarta.persistence.*;
import lombok.*;

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "recipe_videos")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RecipeVideo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String videoUrl;

    @ElementCollection
    private List<String> tags;

    @Column(length = 5000)
    private String description;

    private String thumbnailUrl;

    private Date createdAt = new Date();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column
    private int likes;

    @ManyToMany
    private Set<User> likedBy = new HashSet<>();

    @Transient
    private boolean likedByUser;


}
