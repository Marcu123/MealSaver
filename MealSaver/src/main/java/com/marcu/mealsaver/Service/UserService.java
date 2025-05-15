package com.marcu.mealsaver.Service;

import com.marcu.mealsaver.Dto.LoginRequestDTO;
import com.marcu.mealsaver.Dto.LoginResponseDTO;
import com.marcu.mealsaver.Dto.UserDTO;
import com.marcu.mealsaver.Exception.EmailAlreadyExistsException;
import com.marcu.mealsaver.Exception.UserNotFoundException;
import com.marcu.mealsaver.Exception.UsernameAlreadyExistsException;
import com.marcu.mealsaver.Mapper.UserMapper;
import com.marcu.mealsaver.Model.User;
import com.marcu.mealsaver.Model.VerificationToken;
import com.marcu.mealsaver.Repository.UserRepository;
import com.marcu.mealsaver.Repository.VerificationTokenRepository;
import com.marcu.mealsaver.Security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;
    private final PasswordEncoder passwordEncoder;
    private final VerificationTokenRepository verificationTokenRepository;
    private final EmailService emailService;

    @Value("${app.frontend.base-url}")
    private String frontendBaseUrl;


    @Autowired
    public UserService(UserRepository userRepository,
                       UserMapper userMapper,
                       JwtUtil jwtUtil,
                       AuthenticationManager authenticationManager,
                       PasswordEncoder passwordEncoder,
                       VerificationTokenRepository verificationTokenRepository,
                       EmailService emailService) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.jwtUtil = jwtUtil;
        this.authenticationManager = authenticationManager;
        this.passwordEncoder = passwordEncoder;
        this.verificationTokenRepository = verificationTokenRepository;
        this.emailService = emailService;
    }

    public UserDTO getUserByUsername(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + username));
        return userMapper.toDTO(user);
    }

    public void registerUser(UserDTO userDTO) {
        userRepository.findByUsername(userDTO.getUsername())
                .ifPresent(user -> {
                    throw new UsernameAlreadyExistsException("Username already exists: " + userDTO.getUsername());
                });

        userRepository.findByEmail(userDTO.getEmail())
                .ifPresent(user -> {
                    throw new EmailAlreadyExistsException("Email already exists: " + userDTO.getEmail());
                });

        User user = userMapper.toEntity(userDTO);
        user.setPassword(passwordEncoder.encode(userDTO.getPassword()));
        user.setEnabled(false);

        User savedUser = userRepository.save(user);

        String token = UUID.randomUUID().toString();
        VerificationToken verificationToken = new VerificationToken(token, savedUser,
                Date.from(Instant.now().plus(24, ChronoUnit.HOURS)));

        verificationTokenRepository.save(verificationToken);

        String activationLink = frontendBaseUrl + "/api/auth/verify?token=" + token;
        emailService.sendEmail(user.getEmail(), "Activate your MealSaver account",
                "Welcome to MealSaver!\n\nClick the link below to activate your account:\n" + activationLink);
    }

    public void verifyAccount(String token) {
        VerificationToken verificationToken = verificationTokenRepository.findByToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid verification token"));

        if (verificationToken.getExpiryDate().before(new Date())) {
            verificationTokenRepository.delete(verificationToken);
            throw new RuntimeException("Token expired. Please register again.");
        }

        User user = verificationToken.getUser();
        user.setEnabled(true);
        userRepository.save(user);
        verificationTokenRepository.delete(verificationToken);
    }


    public void initiatePasswordReset(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("User not found with email: " + email));

        String token = UUID.randomUUID().toString();
        VerificationToken resetToken = new VerificationToken(
                token, user, Date.from(Instant.now().plus(1, ChronoUnit.HOURS))
        );

        verificationTokenRepository.save(resetToken);

        String resetLink = frontendBaseUrl + "/api/auth/reset-password?token=" + token;
        emailService.sendEmail(email, "MealSaver - Reset your password",
                "Click the link below to reset your password:\n" + resetLink);
    }

    public void resetPassword(String token, String newPassword) {
        VerificationToken verificationToken = verificationTokenRepository.findByToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid token"));

        if (verificationToken.getExpiryDate().before(new Date())) {
            verificationTokenRepository.delete(verificationToken);
            throw new RuntimeException("Token expired.");
        }

        User user = verificationToken.getUser();
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        verificationTokenRepository.delete(verificationToken);
    }



    public void deleteUser(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + username));
        userRepository.delete(user);
    }

    public void updateUser(String currentUsername, UserDTO dto) {
        User user = userRepository.findByUsername(currentUsername)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        user.setFirstName(dto.getFirstName());
        user.setLastName(dto.getLastName());
        user.setEmail(dto.getEmail());
        user.setUsername(dto.getUsername());

        if (dto.getProfileImageUrl() != null) {
            user.setProfileImageUrl(dto.getProfileImageUrl());
        }

        userRepository.save(user);
    }

    public void updateUserPhoto(String username, String profileImageUrl) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        user.setProfileImageUrl(profileImageUrl);
        userRepository.save(user);
    }



    public LoginResponseDTO loginUser(LoginRequestDTO loginRequestDTO) {
        User user = userRepository.findByUsername(loginRequestDTO.getUsername())
                .orElseThrow(() -> new UserNotFoundException("User not found: " + loginRequestDTO.getUsername()));

        if (!user.isEnabled()) {
            throw new BadCredentialsException("Account not activated. Please check your email.");
        }

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequestDTO.getUsername(), loginRequestDTO.getPassword())
        );

        String jwt = jwtUtil.generateToken(user.getUsername());
        return new LoginResponseDTO(jwt);
    }

    public void changePassword(String username, String oldPassword, String newPassword) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new IllegalArgumentException("Old password is incorrect.");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    public UserDTO getCurrentUserData(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        UserDTO dto = new UserDTO();
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setEmail(user.getEmail());
        dto.setUsername(user.getUsername());
        dto.setProfileImageUrl(user.getProfileImageUrl());
        return dto;
    }

    public List<UserDTO> searchByUsernameContains(String part) {
        return userRepository.findByUsernameContainingIgnoreCase(part)
                .stream()
                .map(userMapper::toDTO)
                .collect(Collectors.toList());
    }


}
