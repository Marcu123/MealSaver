package com.marcu.mealsaver.Service;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
public class ImageService {

    private final Path imageDirectory = Paths.get("src/main/resources/static/images");

    public Resource loadImageAsResource(String imageName) throws IOException {
        Path imagePath = imageDirectory.resolve(imageName + ".jpg").normalize();
        System.out.println("Image path: " + imagePath);
        if (!Files.exists(imagePath)) {
            throw new IOException("Image not found: " + imageName);
        }
        try {
            return new UrlResource(imagePath.toUri());
        } catch (MalformedURLException e) {
            throw new IOException("Error loading image", e);
        }
    }
}
