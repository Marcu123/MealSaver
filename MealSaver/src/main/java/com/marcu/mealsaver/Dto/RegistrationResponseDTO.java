package com.marcu.mealsaver.Dto;

public class RegistrationResponseDTO {
    private String message;

    public RegistrationResponseDTO(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

