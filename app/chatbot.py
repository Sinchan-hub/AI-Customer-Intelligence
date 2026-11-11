
from pathlib import Path

import streamlit as st
import pandas as pd
import ollama

# --------------------------------------------------
# PAGE CONFIGURATION
# --------------------------------------------------

st.set_page_config(
    page_title="Customer Intelligence AI",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

BASE_DIR = Path(__file__).resolve().parent.parent
NOTEBOOK_DIR = BASE_DIR / "notebooks"

# --------------------------------------------------
# LIGHT THEME DESIGN
# --------------------------------------------------

st.markdown("""
<style>
.stApp {
    background-color: #F4F7FC;
    color: #26364A;
}

[data-testid="stSidebar"] {
    background-color: #EAF1FA;
    border-right: 1px solid #DCE5F0;
}

.main-title {
    color: #183153;
    font-size: 30px;
    font-weight: 750;
}

.subtitle {
    color: #718096;
    font-size: 14px;
}

.kpi-card {
    background: white;
    padding: 20px;
    border-radius: 14px;
    border: 1px solid #E0E8F2;
    box-shadow: 0 2px 8px rgba(30, 60, 100, 0.04);
}

.kpi-label {
    color: #718096;
    font-size: 13px;
}

.kpi-value {
    color: #183153;
    font-size: 27px;
    font-weight: 750;
}

.kpi-note {
    color: #16866B;
    font-size: 12px;
}

.section-title {
    color: #183153;
    font-size: 21px;
    font-weight: 700;
}

div.stButton > button {
    background-color: white;
    color: #285B96;
    border: 1px solid #D7E3F1;
    border-radius: 9px;
    min-height: 42px;
}

div.stButton > button:hover {
    background-color: #E7F0FC;
    border-color: #83AEDD;
    color: #183153;
}

[data-testid="stChatMessage"] {
    background-color: white;
    border: 1px solid #E5EBF3;
    border-radius: 12px;
    padding: 12px;
}

[data-testid="stMetric"] {
    background: white;
    border: 1px solid #E0E8F2;
    border-radius: 12px;
    padding: 15px;
}

hr {
    border-color: #DCE5F0;
}
</style>
""", unsafe_allow_html=True)


# --------------------------------------------------
# LOAD PROJECT DATA
# --------------------------------------------------

@st.cache_data
def load_data():

    files = {
        "segmentation": NOTEBOOK_DIR / "customer_segmentation_results.csv",
        "churn": NOTEBOOK_DIR / "customer_churn_predictions.csv",
        "revenue": NOTEBOOK_DIR / "monthly_revenue_predictions.csv",
        "shap": BASE_DIR / "shap_feature_importance.csv"
    }

    data = {}

    for name, path in files.items():
        if path.exists():
            data[name] = pd.read_csv(path)
        else:
            data[name] = None

    return data


data = load_data()

segmentation = data["segmentation"]
churn = data["churn"]
revenue = data["revenue"]
shap_data = data["shap"]


# --------------------------------------------------
# DATA STATUS
# --------------------------------------------------

all_loaded = all(value is not None for value in data.values())

if not all_loaded:
    missing = [
        name for name, value in data.items()
        if value is None
    ]

    st.error(
        "Some project files could not be loaded: "
        + ", ".join(missing)
    )


# --------------------------------------------------
# BUSINESS INSIGHT FUNCTIONS
# --------------------------------------------------


def get_segmentation_result():

    if segmentation is None:
        return "Customer segmentation data is unavailable."

    column = "ML_Customer_Segment"

    if column not in segmentation.columns:
        return "ML_Customer_Segment column was not found."

    counts = segmentation[column].value_counts()
    total = counts.sum()

    result = "## Customer Segmentation Results\n\n"

    top_segment = counts.idxmax()
    top_count = counts.max()
    top_percentage = (top_count / total) * 100

    result += (
        f"### Largest Customer Segment: {top_segment}\n\n"
        f"**{top_count:,} customers ({top_percentage:.2f}%)**\n\n"
    )

    result += "### Segment-wise Distribution\n\n"
    result += "| Customer Segment | Customers | Percentage |\n"
    result += "|---|---:|---:|\n"

    for segment, count in counts.items():
        percentage = (count / total) * 100

        result += (
            f"| {segment} | {count:,} | {percentage:.2f}% |\n"
        )

    return result


def get_churn_result():

    if churn is None:
        return "Churn prediction data is unavailable."

    required = ["Actual_Churn", "Predicted_Churn"]

    if not all(col in churn.columns for col in required):
        return "Required churn columns were not found."

    from sklearn.metrics import accuracy_score, roc_auc_score

    accuracy = accuracy_score(
        churn["Actual_Churn"],
        churn["Predicted_Churn"]
    )

    actual_counts = churn["Actual_Churn"].value_counts()
    predicted_counts = churn["Predicted_Churn"].value_counts()

    result = f"""
CHURN MODEL RESULTS

Test Accuracy: {accuracy * 100:.2f}%

Actual churn-risk customers: {actual_counts.get(1, 0):,}
Actual active customers: {actual_counts.get(0, 0):,}

Predicted churn-risk customers: {predicted_counts.get(1, 0):,}
Predicted active customers: {predicted_counts.get(0, 0):,}

ROC-AUC Score: 0.7925

Important:
The churn label is based on historical inactivity
(Recency greater than 180 days). It is a churn-risk
proxy, not confirmed future customer churn.
"""

    return result


def get_revenue_result():

    if revenue is None:
        return "Revenue prediction data is unavailable."

    return (
        "MONTHLY REVENUE FORECAST RESULTS\n\n"
        + revenue.to_string(index=False)
        + "\n\nModel: Random Forest Regressor\n"
        + "MAE: R$ 33,651.47\n"
        + "RMSE: R$ 38,741.58\n"
        + "R-squared: 0.4907\n\n"
        + "The test period contains four months, "
        + "May to August 2018."
    )


def get_shap_result():

    if shap_data is None:
        return "SHAP feature importance data is unavailable."

    if not {"Feature", "Mean_Absolute_SHAP"}.issubset(
        shap_data.columns
    ):
        return (
            "Expected columns Feature and Mean_Absolute_SHAP "
            "were not found in the SHAP file."
        )

    sorted_data = shap_data.sort_values(
        "Mean_Absolute_SHAP",
        ascending=False
    )

    return (
        "SHAP FEATURE IMPORTANCE\n\n"
        + sorted_data.to_string(index=False)
        + "\n\nThese values represent mean absolute SHAP "
        "importance magnitudes, not percentages or direction."
    )


# --------------------------------------------------
# BUSINESS QUESTION ROUTER
# --------------------------------------------------

def get_business_answer(question):

    q = question.lower()

    if any(word in q for word in [
        "segment", "customer group", "customer category"
    ]):
        return get_segmentation_result()

    if any(word in q for word in [
        "churn accuracy", "churn prediction",
        "churn rate", "churn result", "churn model"
    ]):
        return get_churn_result()

    if any(word in q for word in [
        "shap", "feature importance",
        "important feature", "influential feature"
    ]):
        return get_shap_result()

    if any(word in q for word in [
        "revenue forecast", "revenue prediction",
        "monthly revenue", "forecast revenue"
    ]):
        return get_revenue_result()

    return None


# --------------------------------------------------
# PROJECT CONTEXT FOR OLLAMA
# --------------------------------------------------

def prepare_context():

    return """
You are an AI-powered business intelligence assistant
for an Olist e-commerce customer intelligence project.

PROJECT INFORMATION:

Dataset: Olist Brazilian e-commerce dataset.
Total unique customers: 93,358.

CUSTOMER SEGMENTATION:
Recent Active Customers: 50,642 (54.24%)
Inactive Customers: 37,526 (40.20%)
Loyal Repeat Customers: 2,772 (2.97%)
High-Spending Customers: 2,418 (2.59%)

CHURN MODEL:
Algorithm: Random Forest Classifier.
Accuracy: 74.33%.
ROC-AUC: 0.7925.
Actual churn-risk customers in test data: 11,001.
Actual active customers in test data: 7,671.
Predicted churn-risk customers: 10,897.
Predicted active customers: 7,775.

Churn label 1 means churn-risk/inactive.
Churn label 0 means active.
Churn is a historical inactivity proxy based on
Recency greater than 180 days, not confirmed future churn.

SHAP:
Monetary and Average_Spending_Per_Order are the
two most important features in the SHAP analysis.
SHAP values are mean absolute magnitudes, not
percentages and do not show direction by themselves.

REVENUE FORECASTING:
Algorithm: Random Forest Regressor.
MAE: R$ 33,651.47.
RMSE: R$ 38,741.58.
R-squared: 0.4907.
Test period: May to August 2018.
There are only four test observations.

IMPORTANT INSTRUCTIONS:
1. Answer in simple professional language.
2. Explain technical terms when necessary.
3. Use only the supplied project information.
4. Never invent numerical results.
5. Currency is Brazilian Real (R$), not Indian Rupees.
6. Do not confuse RFM segments with K-Means clusters.
7. Do not claim model accuracy is the percentage of
   customers who will churn.
8. Do not claim SHAP importance values are percentages.
9. If information is unavailable, say so honestly.
10. Keep answers concise and interview-friendly.
"""


# --------------------------------------------------
# OLLAMA RESPONSE
# --------------------------------------------------

def ask_ollama(question):

    response = ollama.chat(
        model="qwen2.5:1.5b",
        messages=[
            {
                "role": "system",
                "content": prepare_context()
            },
            {
                "role": "user",
                "content": question
            }
        ]
    )

    return response["message"]["content"]


# --------------------------------------------------
# SIDEBAR
# --------------------------------------------------

with st.sidebar:

    st.markdown("## 📊 Customer AI")

    st.caption("Business Intelligence Platform")

    st.divider()

    page = st.radio(
        "NAVIGATION",
        [
            "AI Assistant",
            "Customer Segmentation",
            "Churn Analysis",
            "Revenue Forecast",
            "SHAP Insights"
        ]
    )

    st.divider()

    st.markdown("### Project Information")

    st.caption("Dataset: Olist E-commerce")

    st.caption("AI Model: Qwen 2.5")

    st.caption("ML Models: Random Forest")

    st.divider()

    if all_loaded:
        st.success("All project datasets loaded")
    else:
        st.warning("Some datasets are missing")

    if st.button("Clear Chat", use_container_width=True):
        st.session_state.messages = []
        st.rerun()


# --------------------------------------------------
# MAIN HEADER
# --------------------------------------------------

st.markdown(
    '<div class="main-title">Customer Intelligence Dashboard</div>',
    unsafe_allow_html=True
)

st.markdown(
    '<div class="subtitle">AI-powered customer analytics, '
    'churn prediction and business insights</div>',
    unsafe_allow_html=True
)

st.write("")


# --------------------------------------------------
# KPI CARDS
# --------------------------------------------------

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.markdown("""
    <div class="kpi-card">
        <div class="kpi-label">Total Customers</div>
        <div class="kpi-value">93,358</div>
        <div class="kpi-note">Unique customers</div>
    </div>
    """, unsafe_allow_html=True)

with col2:
    st.markdown("""
    <div class="kpi-card">
        <div class="kpi-label">Churn Accuracy</div>
        <div class="kpi-value">74.33%</div>
        <div class="kpi-note">Random Forest model</div>
    </div>
    """, unsafe_allow_html=True)

with col3:
    st.markdown("""
    <div class="kpi-card">
        <div class="kpi-label">ROC-AUC Score</div>
        <div class="kpi-value">0.7925</div>
        <div class="kpi-note">Churn model</div>
    </div>
    """, unsafe_allow_html=True)

with col4:
    st.markdown("""
    <div class="kpi-card">
        <div class="kpi-label">Revenue Model R²</div>
        <div class="kpi-value">0.4907</div>
        <div class="kpi-note">Test performance</div>
    </div>
    """, unsafe_allow_html=True)


st.write("")


# --------------------------------------------------
# NAVIGATION PAGES
# --------------------------------------------------

if page == "Customer Segmentation":

    st.markdown("## Customer Segmentation")

    if segmentation is not None:
        if "ML_Customer_Segment" in segmentation.columns:

            counts = (
                segmentation["ML_Customer_Segment"]
                .value_counts()
            )

            st.bar_chart(counts)

            st.dataframe(
                counts.rename("Customer Count"),
                use_container_width=True
            )
        else:
            st.error("ML_Customer_Segment column not found.")

elif page == "Churn Analysis":

    st.markdown("## Customer Churn Analysis")

    if churn is not None:
        st.write(get_churn_result())

        actual_counts = churn["Actual_Churn"].value_counts()

        st.bar_chart(actual_counts)

elif page == "Revenue Forecast":

    st.markdown("## Monthly Revenue Forecast")

    if revenue is not None:
        st.write(get_revenue_result())

        numeric_columns = [
            col for col in [
                "Actual_Revenue",
                "Predicted_Revenue"
            ]
            if col in revenue.columns
        ]

        if numeric_columns:
            st.line_chart(
                revenue.set_index("Year_Month")[numeric_columns]
                if "Year_Month" in revenue.columns
                else revenue[numeric_columns]
            )

elif page == "SHAP Insights":

    st.markdown("## Explainable AI - SHAP")

    if shap_data is not None:
        st.write(get_shap_result())

        if {
            "Feature",
            "Mean_Absolute_SHAP"
        }.issubset(shap_data.columns):

            chart_data = shap_data.sort_values(
                "Mean_Absolute_SHAP",
                ascending=True
            ).set_index("Feature")

            st.bar_chart(
                chart_data["Mean_Absolute_SHAP"]
            )

elif page == "AI Assistant":

    st.markdown("## 🤖 AI Business Assistant")

    st.caption(
        "Ask questions about customer segments, "
        "churn, revenue and model explanations."
    )

    st.markdown("### Suggested Questions")

    suggestions = [
        "Which customer segment has the most customers?",
        "Explain the churn prediction model.",
        "What are the most important SHAP features?",
        "Explain the revenue forecasting results."
    ]

    cols = st.columns(2)

    selected_question = None

    for i, suggestion in enumerate(suggestions):
        with cols[i % 2]:
            if st.button(
                suggestion,
                key=f"suggestion_{i}",
                use_container_width=True
            ):
                selected_question = suggestion

    st.divider()

    if "messages" not in st.session_state:
        st.session_state.messages = []

    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])

    user_question = st.chat_input(
        "Ask your business question here..."
    )

    if selected_question:
        user_question = selected_question

    if user_question:

        st.session_state.messages.append({
            "role": "user",
            "content": user_question
        })

        with st.chat_message("user"):
            st.markdown(user_question)

        with st.chat_message("assistant"):

            with st.spinner("Analyzing your business data..."):

                try:

                    answer = get_business_answer(user_question)

                    if answer is None:
                        answer = ask_ollama(user_question)

                    st.markdown(answer)

                except Exception as e:
                    answer = (
                        "I encountered an error while processing "
                        "your question. Please check whether "
                        "Ollama is running and the model is installed.\n\n"
                        f"Error: {e}"
                    )

                    st.error(answer)

        st.session_state.messages.append({
            "role": "assistant",
            "content": answer
        })


# --------------------------------------------------
# FOOTER
# --------------------------------------------------

st.divider()

st.markdown(
    """
    <div style="text-align:center; color:#8795A8; font-size:12px;">
    AI Customer Intelligence & Business Revenue Prediction System
    <br>
    Built using Python | Streamlit | Machine Learning | SHAP | Ollama
    </div>
    """,
    unsafe_allow_html=True
)
