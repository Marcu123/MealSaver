package com.marcu.mealsaver.Dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class FoodDTO {

    @NotNull(message = "Id is required")
    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    @NotNull(message = "Size is required")
    @Min(value = 1, message = "Size must be at least 1")
    private Integer size;

    @NotNull(message = "Expiration date is required")
    private Date expirationDate;

    @NotBlank(message = "Username is required")
    private String username;
}

