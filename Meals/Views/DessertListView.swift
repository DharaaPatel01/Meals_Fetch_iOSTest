//
//  DessertListView.swift
//  MealApp
//
//  Created by Dhara Patel on 12/02/24.
//

import SwiftUI

struct DessertListView: View {
    @State var isLoading = false
    @State private var desserts: [MealsListModel] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if isLoading {
                        HStack(spacing: 15) {
                            ProgressView()
                            Text("Loading…")
                        }
                    }
                    else {
                        List(desserts.sorted { $0.strMeal < $1.strMeal }) { dessert in
                            NavigationLink(destination: DessertDetailView(dessert: dessert)) {
                                HStack(alignment: .center) {
                                    if let imageURL = dessert.strMealThumb {
                                        AsyncImage(url: URL(string: imageURL)) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width:30, height: 30)
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                                            case .failure(let error):
                                                // Handle the failure case if needed
                                                Text("Failed to load image: \(error.localizedDescription)")
                                            case .empty:
                                                // Placeholder or loading indicator can be shown here if needed
                                                EmptyView()
                                            @unknown default:
                                                // Handle any future cases here
                                                EmptyView()
                                            }
                                        }
                                    }
                                    Text(dessert.strMeal)
                                }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                    return 40
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Desserts")
            .onAppear {
                isLoading = true
                NetworkManager.fetchMeals(url: URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!) { result in
                    defer {
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    }
                    switch result {
                    case .success(let desserts):
                        self.desserts = desserts
                    case .failure(let error):
                        debugPrint(error)
                    }
                }
            }
        }
    }
}

#Preview {
    DessertListView()
}
