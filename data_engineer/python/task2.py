import requests
import pandas as pd

# Получение данных по постам
posts_url = "http://jsonplaceholder.typicode.com/posts"
posts_response = requests.get(posts_url)
posts_data = posts_response.json()

# Получение данных по комментариям
comments_url = "http://jsonplaceholder.typicode.com/comments"
comments_response = requests.get(comments_url)
comments_data = comments_response.json()

# преобразуем полученные данные в датафреймы
df_posts = pd.DataFrame(posts_data)
#print(df_posts.head())

df_comments = pd.DataFrame(comments_data)
#print(df_comments.head())

# считаем количество комментариев для каждого поста
df_comments_count = df_comments.groupby('postId').size().reset_index(name='comments_count')
#print(df_comments_count.head())


# объединяем данные по постам и комментариям
df_posts_comments = df_posts.merge(df_comments_count, 
								   left_on='id', 
								   right_on='postId', 
								   how='left')



# вычисляем среднее количество комментариев к посту для каждого пользователя
df_user_avg_comments = df_posts_comments.groupby('userId')['comments_count'].mean().reset_index()
df_user_avg_comments.rename(columns={'comments_count': 'average_comments_per_post'}, inplace=True)
#print(df_user_avg_comments.head())

# преобразуем DataFrame в словарь (по заданию)
user_avg_comments_dict = (df_user_avg_comments.set_index('userId')
						  					  .to_dict()['average_comments_per_post'])

# результат
print(user_avg_comments_dict)
