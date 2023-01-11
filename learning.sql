SELECT SUM(`b_quantity`) AS `sum`,
MIN(`b_quantity`) AS `min`,
MAX(`b_quantity`) AS `max`,
AVG(`b_quantity`) AS `avg`
FROM `books`;

/*сколько всего разных книг зарегистрировано*/
SELECT COUNT(*) AS `total_books`
FROM `books`;

/*показать поимённый список читателей с указанием количества полных тёзок по каждому имени*/
SELECT `s_name`,
COUNT(*) AS `people_count`
FROM `subscribers`
GROUP BY `s_name`;

/*показать, сколько всего экземпляров книг выдано читателям*/
SELECT COUNT(`sb_book`) AS `in_use`
FROM `subscriptions`
WHERE `sb_is_active` = 'Y';

/*показать все книги в библиотеке в порядке возрастания их года издания*/
SELECT `b_name`,
`b_year`
FROM `books`
ORDER BY `b_year` ASC;

/*показать книги, изданные в период 1990-2000 годов, представленные в библиотеке в количестве трёх и более экземпляров.*/
SELECT `b_name`,
`b_year`,
`b_quantity`
FROM `books`
WHERE `b_year` BETWEEN 1990 AND 2000
AND `b_quantity` >= 3;

/*показать просто одну любую книгу, количество экземпляров которой максимально (равно максимуму по всем книгам)*/
select `b_name`, `b_quantity`
from `books`
order by `b_quantity` desc
limit 1;

/*показать все книги, представленные равным максимальным
количеством экземпляров*/
SELECT `b_name`,
`b_quantity`
FROM `books`
WHERE `b_quantity` = (SELECT MAX(`b_quantity`)
FROM `books`);

/*показать, сколько в среднем экземпляров книг сейчас на руках у каждого читателя*/
SELECT AVG(`books_per_subscriber`) AS `avg_books`
FROM (SELECT COUNT(`sb_book`) AS `books_per_subscriber`
FROM `subscriptions`
WHERE `sb_is_active` = 'Y'
GROUP BY `sb_subscriber`) AS `count_subquery`;

/*показать, на сколько в среднем дней читатели берут книги (учесть только случаи, когда книги были возвращены)*/
SELECT AVG(DATEDIFF(`sb_finish`, `sb_start`)) AS `avg_days`
FROM `subscriptions`
WHERE `sb_is_active` = 'N';

/*показать по каждому году, сколько раз в этот год читатели брали книги*/
SELECT YEAR(`sb_start`) AS `year`,
COUNT(`sb_id`) AS `books_taken`
FROM `subscriptions`
GROUP BY `year`
ORDER BY `year`;

/*показать, сколько книг было возвращено и не возвращено в библиотеку*/
SELECT IF(`sb_is_active` = 'Y', 'Not returned', 'Returned') AS `status`,
COUNT(`sb_id`) AS `books`
FROM `subscriptions`
GROUP BY `status`
ORDER BY `status` DESC;

/*показать всю человекочитаемую информацию обо всех книгах (т.е. название, автора, жанр). ОБЪЕДИНЕНИЕ ПО ОДНОИМЕННЫМ ПОЛЯМ*/
SELECT `b_name`, `a_name`, `g_name`
FROM `books`
JOIN `m2m_books_authors` using (`b_id`)
JOIN `authors` using (`a_id`)
JOIN `m2m_books_genres` using (`b_id`)
JOIN `genres` using (`g_id`);

/*всю человекочитаемую информацию обо всех обращениях в библиотеку (т.е. имя читателя, название взятой книги). ОБЪЕДИНЕНИ ПО РАЗНОИМЕННЫМ ПОЛЯМ*/
SELECT `b_name`,`s_id`,`s_name`,`sb_start`,`sb_finish`
FROM `books`
JOIN `subscriptions` ON `b_id` = `sb_book`
JOIN `subscribers` ON `sb_subscriber` = `s_id`;

/*показать список книг, относящихся ровно к одному жанру*/
SELECT `b_id`, `b_name`,count(`g_name`) as `how much` 
FROM `books`
JOIN `m2m_books_genres` using (`b_id`)
JOIN `genres` using (`g_id`)
GROUP BY `b_id`
HAVING `how much` = 1;

/*показать все книги с их авторами (дублирование названий книг не допускается*/
SELECT `b_name` AS `book`,
GROUP_CONCAT(`a_name` ORDER BY `a_name` SEPARATOR ', ') AS `author(s)`
FROM `books`
JOIN  `m2m_books_authors` USING (`b_id`)
JOIN `authors` USING(`a_id`)
GROUP BY `b_id`
ORDER BY `b_name`;

/*показать все книги с их жанрами (дублирование названий книг не допускается)*/
select `b_name` as `book`,
group_concat(`g_name` order by `g_name` separator ',' ) as `genre(s)`
from `books`
join `m2m_books_genres` using (`b_id`)
join `genres` using (`g_id`)
group by `b_id`;

/*показать список читателей, когда-либо бравших в библиотеке книги (использовать JOIN)*/
select distinct `s_id`, `s_name`
from `subscribers`
join `subscriptions` on `s_id`=`sb_subscriber`;

/*показать список читателей, когда-либо бравших в библиотеке книги (не использовать JOIN)*/
select `s_id`, `s_name`
from `subscribers`
where `s_id` in (select distinct `sb_subscriber` from `subscriptions`);

/*показать список читателей, никогда не бравших в библиотеке книги (использовать JOIN).*/
select distinct `s_id`, `s_name`
from `subscribers`
left join `subscriptions` on `s_id` = `sb_subscriber`
where `sb_subscriber` is null;

/*показать список книг, которые когда-либо были взяты читателями.*/
select distinct `b_id`, `b_name`
from `books`
join `subscriptions` on `b_id`=`sb_book`;

/*показать список книг, которые никто из читателей никогда не брал*/
select `b_id`, `b_name`
from `books`
left join `subscriptions` on `b_id`=`sb_book`
where `sb_book` is null;

/*показать список читателей, у которых сейчас на руках нет книг (использовать JOIN)*/
SELECT `s_id`, `s_name`
FROM `subscribers`
LEFT JOIN `subscriptions`
ON `s_id` = `sb_subscriber`
GROUP BY `s_id`
HAVING COUNT(IF(`sb_is_active` = 'Y', `sb_is_active`, NULL)) = 0; /*признак того, что читатель вернул все книги*/

/*показать список читателей, у которых сейчас на руках нет книг (не использовать JOIN).*/
SELECT `s_id`, `s_name`
FROM `subscribers`
WHERE `s_id` NOT IN (SELECT DISTINCT `sb_subscriber`
FROM `subscriptions`
WHERE `sb_is_active` = 'Y');

/*показать книги из жанров «Программирование» и/или «Классика» (JOIN; идентификаторы жанров известны)*/
select `b_id`, `b_name`
from `books`
WHERE `b_id` IN (SELECT DISTINCT `b_id`
FROM `m2m_books_genres`
WHERE `g_id` IN ( 2, 5 )) /*узнать идентификаторы из таблицы m2m_genres*/
ORDER BY `b_name` ASC;

SELECT DISTINCT `b_id`, `b_name`
FROM `books`
JOIN `m2m_books_genres` USING ( `b_id` )
WHERE `g_id` IN ( 2, 5 )
ORDER BY `b_name` ASC;

/*показать книги из жанров «Программирование» и/или «Классика» (JOIN; идентификаторы жанров НЕизвестны)*/
SELECT DISTINCT `b_id`, `b_name`
FROM `books`
JOIN `m2m_books_genres` USING ( `b_id` )
WHERE `g_id` IN (SELECT `g_id` FROM `genres` WHERE `g_name` IN ( N'Программирование', N'Классика' ))
ORDER BY `b_name` ASC;

/*показать книги, у которых более одного автора*/
select `b_id`, `b_name`, count(`a_id`) as `author_count`
from `books`
join `m2m_books_authors` using (`b_id`)
GROUP BY `b_id`
HAVING `author_count` > 1;

/*показать, сколько реально экземпляров каждой книги сейчас есть в библиотеке*/
SELECT DISTINCT `b_id`, `b_name`, ( `b_quantity` - (SELECT COUNT(`int`.`sb_book`)
FROM `subscriptions` AS `int`
WHERE `int`.`sb_book` = `ext`.`sb_book` AND `int`.`sb_is_active` = 'Y')) AS `real_count`
FROM `books`
LEFT OUTER JOIN `subscriptions` AS `ext`
ON `books`.`b_id` = `ext`.`sb_book`
ORDER BY `real_count` DESC;

/*показать читаемость авторов, т.е. всех авторов и то количество раз, которое книги этих авторов были взяты читателями*/
select `a_id`, `a_name`, COUNT(`sb_book`) AS `books`
FROM `authors`
JOIN `m2m_books_authors` USING ( `a_id` ) /*нужно собрать воедино информацию об авторах, книгах и фактах выдачи книг (это достигается за счёт двух JOIN), после чего подсчитать количество фактов выдачи книг, сгруппировав результаты подсчёта по идентификаторам авто-ров*/
LEFT OUTER JOIN `subscriptions`
ON `m2m_books_authors`.`b_id` = `sb_book`
GROUP BY `a_id`
ORDER BY `books` DESC;

/*показать авторов, одновременно работавших в двух и более жанрах (т.е. хотя бы одна книга автора должна одновременно относиться к двум и более жанрам)*/
SELECT `a_id`, `a_name`, MAX(`genres_count`) AS `genres_count`
FROM (SELECT `a_id`, `a_name`, COUNT(`g_id`) AS `genres_count`
FROM `authors`
JOIN `m2m_books_authors` USING (`a_id`)
JOIN `m2m_books_genres` USING (`b_id`)
GROUP BY `a_id`, `b_id`
HAVING `genres_count` > 1) AS `prepared_data`
GROUP BY `a_id`;

use library;

