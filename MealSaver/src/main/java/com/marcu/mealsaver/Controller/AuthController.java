package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.*;
import com.marcu.mealsaver.Model.User;
import com.marcu.mealsaver.Model.VerificationToken;
import com.marcu.mealsaver.Repository.UserRepository;
import com.marcu.mealsaver.Repository.VerificationTokenRepository;
import com.marcu.mealsaver.Security.JwtUtil;
import com.marcu.mealsaver.Service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Validated
public class AuthController {

    private final UserService userService;
    private final VerificationTokenRepository tokenRepo;
    private final UserRepository userRepository;

    @Autowired
    public AuthController(UserService userService, VerificationTokenRepository tokenRepo, UserRepository userRepository) {
        this.userService = userService;
        this.tokenRepo = tokenRepo;
        this.userRepository = userRepository;
    }

    @PostMapping("/register")
    public ResponseEntity<RegistrationResponseDTO> register(@Valid @RequestBody UserDTO userDTO) {
        userService.registerUser(userDTO);

        RegistrationResponseDTO response = new RegistrationResponseDTO(
                "Account created. Please check your email to activate your account."
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }


    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> loginUser(@Valid @RequestBody LoginRequestDTO loginRequestDTO) {
        LoginResponseDTO loginResponseDTO = userService.loginUser(loginRequestDTO);
        return ResponseEntity.ok(loginResponseDTO);
    }

    @GetMapping("/verify")
    public ResponseEntity<String> verifyAccount(@RequestParam String token) {
        try {
            userService.verifyAccount(token);
            return ResponseEntity.ok("Account activated! You can now log in.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }


    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@Valid @RequestBody ForgotPasswordRequestDTO request) {
        userService.initiatePasswordReset(request.getEmail());
        return ResponseEntity.ok("Check your email for password reset instructions.");
    }


    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@Valid @RequestBody ResetPasswordRequestDTO request) {
        userService.resetPassword(request.getToken(), request.getPassword());
        return ResponseEntity.ok("Password reset successfully.");
    }






}
