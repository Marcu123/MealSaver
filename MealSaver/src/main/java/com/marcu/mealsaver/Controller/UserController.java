package com.marcu.mealsaver.Controller;

import com.marcu.mealsaver.Dto.PasswordDTO;
import com.marcu.mealsaver.Dto.UserDTO;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import com.marcu.mealsaver.Service.UserService;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@Validated
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{username}")
    public ResponseEntity<UserDTO> getUserByUsername(@PathVariable String username) {
        return ResponseEntity.ok(userService.getUserByUsername(username));
    }

    @PutMapping("/update-profile")
    public ResponseEntity<Void> updateProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UserDTO userDTO
    ) {
        userService.updateUser(userDetails.getUsername(), userDTO);
        return ResponseEntity.noContent().build();
    }



    @DeleteMapping("/{username}")
    public ResponseEntity<Void> deleteUser(@PathVariable String username) {
        userService.deleteUser(username);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/change-password")
    public ResponseEntity<String> changePassword(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody PasswordDTO passwordDTO
    ) {
        userService.changePassword(
                userDetails.getUsername(),
                passwordDTO.getOldPassword(),
                passwordDTO.getNewPassword()
        );
        return ResponseEntity.ok("Password changed successfully.");
    }

    @GetMapping("/me")
    public ResponseEntity<UserDTO> getCurrentUser(@AuthenticationPrincipal UserDetails userDetails) {
        UserDTO userDTO = userService.getCurrentUserData(userDetails.getUsername());
        return ResponseEntity.ok(userDTO);
    }

    @PutMapping("/upload-profile-image")
    public ResponseEntity<Void> uploadImageByUsername(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String url = request.get("url");

        if (username == null || url == null) {
            return ResponseEntity.badRequest().build();
        }

        userService.updateUserPhoto(username, url);

        return ResponseEntity.noContent().build();
    }





}

