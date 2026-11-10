# AI-Powered Customer Intelligence & Business Revenue Prediction System

An end-to-end Data Science and Business Intelligence project built using the Olist Brazilian E-Commerce dataset. This project combines Machine Learning, Explainable AI, SQL, Power BI and Generative AI to analyze customer behavior, predict churn risk, segment customers and forecast business revenue.

## Project Overview

The system transforms raw e-commerce data into actionable business insights through data analytics, predictive modeling and an interactive AI-powered assistant.

## Key Features

- **Exploratory Data Analysis:** Analyzes customer behavior, order patterns, revenue and product performance.
- **Feature Engineering:** Creates customer-level features such as recency, frequency, monetary value and purchase intensity.
- **Customer Segmentation:** Applies RFM analysis and K-Means clustering to identify customer groups.
- **Churn Prediction:** Uses Machine Learning to identify customers at risk of inactivity.
- **Explainable AI:** Uses SHAP to understand the features influencing model predictions.
- **Revenue Forecasting:** Uses Random Forest Regression to predict monthly revenue.
- **SQL Analysis:** Performs customer, order, product and payment analysis.
- **Power BI Dashboard:** Presents interactive business insights through KPI cards, charts and maps.
- **Generative AI Assistant:** Provides data-driven answers through a Streamlit application powered by a locally hosted Ollama model.

## Technology Stack

| Area | Technologies |
|---|---|
| Programming | Python, SQL |
| Data Analysis | Pandas, NumPy |
| Visualization | Matplotlib, Seaborn, Power BI |
| Machine Learning | Scikit-learn |
| Explainable AI | SHAP |
| Generative AI | Ollama, Qwen 2.5 |
| Application | Streamlit |
| Database | MySQL |
| Development | Jupyter Notebook, VS Code, Git, GitHub |

## Dataset

The project uses the publicly available Olist Brazilian E-Commerce dataset.

The dataset contains information about customers, orders, order items, payments, products, sellers, reviews and product categories.

## Machine Learning Results

### Customer Segmentation

K-Means clustering identified four customer groups:

| Customer Segment | Customers |
|---|---:|
| Recent Active Customers | 50,642 |
| Inactive Customers | 37,526 |
| Loyal Repeat Customers | 2,772 |
| High-Spending Customers | 2,418 |

### Churn Prediction

- Model Accuracy: **74.33%**
- ROC-AUC Score: **0.7925**

Note: Churn is defined using a historical inactivity threshold of more than 180 days. It is an inactivity-based proxy rather than confirmed future churn.

### Revenue Forecasting

| Evaluation Metric | Result |
|---|---:|
| MAE | R$33,651.47 |
| RMSE | R$38,741.58 |
| R² Score | 0.4907 |

Revenue forecasting was evaluated on four chronological test months. Results should be interpreted in light of this relatively small test set.

## Project Structure

```text
AI_Customer_Intelligence/
├── app/
├── datasets/
├── cleaned_data/
├── notebooks/
├── models/
├── sql/
├── dashboard/
├── reports/
├── shap_feature_importance.csv
├── requirements.txt
├── .gitignore
└── README.md
```

## Installation and Execution

### 1. Clone the repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
cd AI_Customer_Intelligence
```

### 2. Create a virtual environment

```bash
python -m venv venv
```

Activate it on Windows:

```bash
venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Install and start Ollama

Install Ollama and download the model:

```bash
ollama pull qwen2.5:1.5b
```

Ensure Ollama is running locally.

### 5. Run the application

```bash
streamlit run app/chatbot.py
```

## Dashboard

The Power BI dashboard includes business overview KPIs, monthly revenue trends, product category analysis, customer segmentation, order status, payment methods and customer geographical distribution.

Open the Power BI file inside the `dashboard/` folder using Power BI Desktop.

## Future Enhancements

- Save and integrate reusable trained Machine Learning models.
- Improve churn prediction using future-period validation.
- Explore additional forecasting models.
- Deploy the Streamlit application to a cloud platform.
- Extend the AI assistant with more interactive analytical capabilities.

## Author

**Sinchan G Birsal**

## Acknowledgements

Dataset: Olist Brazilian E-Commerce Public Dataset.
