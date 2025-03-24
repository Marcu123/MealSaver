package com.marcu.mealsaver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@SpringBootApplication
@EnableScheduling
public class MealSaverApplication {

	public static void main(String[] args) {
		SpringApplication.run(MealSaverApplication.class, args);
	}

}
