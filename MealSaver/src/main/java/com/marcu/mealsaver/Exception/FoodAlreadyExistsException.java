package com.marcu.mealsaver.Exception;

public class FoodAlreadyExistsException extends RuntimeException {
    public FoodAlreadyExistsException(String message) {
        super(message);
    }
}
