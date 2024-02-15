//
//  NetworkManager.swift
//  MealApp
//
//  Created by Dhara Patel on 12/02/24.
//

import Foundation

class NetworkManager {
    /// FETCHING Dessert API response
    ///
    /// - Parameter value: URL
    /// - Returns: Response
    static func fetchMeals(url: URL, completion: @escaping (Result<[MealsListModel], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                // Decode the top-level JSON object as a dictionary
                let json = try JSONDecoder().decode([String: [MealsListModel]].self, from: data)
                
                // Extract the meals array from the dictionary
                if let meals = json["meals"] {
                    // Filter out meals with empty names
                    let filteredMeals = meals.filter { !$0.strMeal.isEmpty }
                    completion(.success(filteredMeals))
                } else {
                    // If meals key is not found or if it's nil, return an error
                    let error = NSError(domain: "com.yourdomain.json", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format: Meals key not found"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }

    /// FETCHING Meal Details API response
    ///
    /// - Parameter value: mealId (for details)
    /// - Returns: Response
    static func fetchMealDetails(id: String, completion: @escaping (Result<MealsListModel, Error>) -> Void) {
        let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)")!
        fetchMeals(url: url) { result in
            switch result {
            case .success(let meals):
                guard let meal = meals.first else { return }
                completion(.success(meal))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
