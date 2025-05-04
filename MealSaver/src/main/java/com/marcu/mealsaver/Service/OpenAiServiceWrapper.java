package com.marcu.mealsaver.Service;

import com.openai.client.OpenAIClient;
import com.openai.client.okhttp.OpenAIOkHttpClient;
import com.openai.models.ChatModel;
import com.openai.models.chat.completions.ChatCompletion;
import com.openai.models.chat.completions.ChatCompletionCreateParams;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

@Service
public class OpenAiServiceWrapper {

    private final OpenAIClient openAiClient;

    public OpenAiServiceWrapper() {
        String apiKey = System.getenv("OPENAI_API_KEY");

        if (apiKey == null || apiKey.isEmpty()) {
            throw new IllegalStateException("OPENAI_API_KEY is not set in environment variables");
        }

        this.openAiClient = OpenAIOkHttpClient.builder()
                .apiKey(apiKey)
                .build();
    }

    public JSONArray generateJsonArrayResponse(String prompt) {
        ChatCompletionCreateParams params = ChatCompletionCreateParams.builder()
                .model(ChatModel.GPT_4O_MINI_2024_07_18)
                .addUserMessage(prompt)
                .temperature(0.8)
                .build();

        ChatCompletion completion = openAiClient.chat().completions().create(params);
        String content = completion.choices().get(0).message().content().orElse("");
        System.out.println("OpenAI JSON:\n" + content);

        return new JSONArray(content);
    }
}
