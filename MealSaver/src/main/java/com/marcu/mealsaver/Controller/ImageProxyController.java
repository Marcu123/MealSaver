package com.marcu.mealsaver.Controller;

import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/proxy")
public class ImageProxyController {

    @GetMapping("/image")
    public ResponseEntity<byte[]> proxyImage(@RequestParam String url) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.add("User-Agent", "Mozilla/5.0");
            headers.add("Referer", "https://www.google.com");
            headers.add("Accept", "*/*");

            HttpEntity<String> entity = new HttpEntity<>(headers);

            ResponseEntity<byte[]> response = new RestTemplate().exchange(
                    url,
                    HttpMethod.GET,
                    entity,
                    byte[].class
            );

            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(response.getBody());

        } catch (Exception e) {
            System.out.println("Proxy failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY).build();
        }
    }

}

