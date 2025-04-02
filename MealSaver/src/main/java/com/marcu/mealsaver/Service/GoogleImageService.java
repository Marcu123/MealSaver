package com.marcu.mealsaver.Service;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Service
public class GoogleImageService {

    private static final String API_KEY = System.getenv("GOOGLE_SEARCH_API_KEY");
    private static final String SEARCH_ENGINE_ID = System.getenv("GOOGLE_SEARCH_ENGINE_ID");

    private static final String GOOGLE_SEARCH_URL =
            "https://www.googleapis.com/customsearch/v1?key=%s&cx=%s&q=%s&searchType=image&num=1";

    public String findImageForTitle(String title) {
        try {
            String encodedQuery = URLEncoder.encode(title + " food dish", StandardCharsets.UTF_8);
            String url = String.format(GOOGLE_SEARCH_URL, API_KEY, SEARCH_ENGINE_ID, encodedQuery);

            RestTemplate restTemplate = new RestTemplate();
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);

            if (response.getStatusCode() == HttpStatus.OK) {
                JSONObject json = new JSONObject(response.getBody());
                JSONArray items = json.optJSONArray("items");

                if (items != null && !items.isEmpty()) {
                    return items.getJSONObject(0).getString("link");
                }
            }
        } catch (Exception e) {
            System.out.println("Google image search failed: " + e.getMessage());
        }

        return "/images/logo.png";
    }
}
