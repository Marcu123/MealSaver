package com.marcu.mealsaver.Model;

import jakarta.annotation.Nullable;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.util.Date;
import java.util.List;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class User{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    @NotBlank(message = "First name is mandatory")
    private String firstName;

    @Column(nullable = false, length = 50)
    @NotBlank(message = "Last name is mandatory")
    private String lastName;

    @Column(nullable = false, unique = true, length = 100)
    @NotBlank(message = "Email is mandatory")
    private String email;

    @Column(nullable = false, unique = true, length = 50)
    @NotBlank(message = "Username is mandatory")
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    @CreationTimestamp
    private Date createdAt;

    @Column(nullable = false)
    @CreationTimestamp
    private Date updatedAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Nullable
    private List<Food> foods;

    @Column(nullable = false)
    private boolean enabled = false;



}
