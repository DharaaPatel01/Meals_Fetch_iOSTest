//
//  DessertDetailView.swift
//  MealApp
//
//  Created by Dhara Patel on 12/02/24.
//

import Foundation
import SwiftUI

struct DessertDetailView: View {
    @State var dessert: MealsListModel
    
    var body: some View {
        GeometryReader { metrics in
            ScrollView {
                VStack(alignment: .leading) {
                    Text(dessert.strMeal)
                        .font(.title)
                        .padding(.leading)
                          
                    //This was not asked in the exercise, and can be commented or removed to not show the image.
                    if let imageURL = dessert.strMealThumb {
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: metrics.size.width * 0.5, height: metrics.size.width * 0.5)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .frame(maxWidth: .infinity)
                                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            case .failure(let error):
                                // Handle the failure case if needed
                                Text("Failed to load image: \(error.localizedDescription)")
                            case .empty:
                                // Placeholder or loading indicator can be shown here if needed
                                ProgressView()
                            @unknown default:
                                // Handle any future cases here
                                EmptyView()
                            }
                        }
                    }
                    
                    Text("Ingredients")
                        .font(.headline)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    
                    //MARK: Getting ingredients
                    //The following code assumes that there won't be more than 20 ingredients based on API response
                    ForEach(1...20, id: \.self) { index in
                        let data = self.getIngredientAndMeasure(index: index)
                        if let ingredient = data.ingredient, let measurement = data.measurement, !ingredient.isEmpty {
                            Text("\(ingredient): \(measurement)")
                                .font(.callout)
                                .padding(EdgeInsets(top: 2, leading: 16, bottom: 0, trailing: 16))
                                
                        }
                    }
                    
                    Text("Instructions")
                        .font(.headline)
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                    
                    Text(dessert.strInstructions ?? "No instructions available")
                        .font(.callout)
                        .multilineTextAlignment(.leading)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    
                }
            }
        }.onAppear {
            NetworkManager.fetchMealDetails(id: dessert.idMeal) { result in
                switch result {
                case .success(let dessert):
                    self.dessert = dessert
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }
    
    func getIngredientAndMeasure(index: Int) -> (ingredient: String?, measurement: String?) {
        let mirror = Mirror(reflecting: dessert)
        let ingredientKey = "strIngredient\(index)"
        let measureKey = "strMeasure\(index)"
        let ingredient = mirror.children.first(where: { $0.label == ingredientKey })?.value as? String
        let measure = mirror.children.first(where: { $0.label == measureKey })?.value as? String
        return (ingredient, measure)
    }
}
