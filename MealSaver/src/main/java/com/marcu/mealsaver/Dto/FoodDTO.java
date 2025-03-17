package com.marcu.mealsaver.Dto;

import jakarta.validation.constraints.NotBlank;
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

    @NotBlank(message = "Id is mandatory")
    private Long id;

    @NotBlank(message = "Name is mandatory")
    private String name;

    @NotBlank(message = "Size is mandatory")
    private Integer size;

    @NotBlank(message = "Expiration date is mandatory")
    private Date expirationDate;

    @NotBlank(message = "Username is mandatory")
    private String username;
}
