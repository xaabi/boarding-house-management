package com.kos.app.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;
import java.util.Map;

@Service
public class AnalyticsService {

    private final RestTemplate restTemplate;

    @Value("${python.analytics.service.url:http://localhost:8000}")
    private String pythonServiceUrl;

    public AnalyticsService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<Map<String, Object>> getOccupancyTrend(Long kostId, Integer year) {
        UriComponentsBuilder builder = UriComponentsBuilder
                .fromHttpUrl(pythonServiceUrl + "/api/analytics/occupancy-trend")
                .queryParam("year", year);

        if (kostId != null) {
            builder.queryParam("kost_id", kostId);
        }

        String targetUrl = builder.toUriString();

        ResponseEntity<List<Map<String, Object>>> response = restTemplate.exchange(
                targetUrl,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<Map<String, Object>>>() {}
        );

        return response.getBody();
    }
}