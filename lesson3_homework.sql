USE vk;

-- table for checking if there are any in-law or by marriage relationships between users
DROP TABLE IF EXISTS relationships; 
CREATE TABLE relationships (
	`who_id` BIGINT UNSIGNED NOT NULL,
	`to_whom_id` BIGINT UNSIGNED NOT NULL,
	`type` ENUM ('married', 'engaged', 'dating', 'sister', 'brother', 'cousin', 'mother', 'father', 'son', 'daughter'),
	PRIMARY KEY (who_id, to_whom_id) COMMENT 'combined key',
	FOREIGN KEY (who_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (to_whom_id) REFERENCES users(id) ON DELETE CASCADE,
	CHECK (who_id <> to_whom_id)
);

-- table for photo comments
DROP TABLE IF EXISTS photo_comments;
CREATE TABLE photo_comments (
	id SERIAL, 
	user_commented_id BIGINT UNSIGNED NOT NULL,
	`comment` VARCHAR(255),
	photo_album_id BIGINT UNSIGNED NOT NULL,
	photo_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW() COMMENT 'time when comment was left',
	INDEX photo_comment_idx (photo_album_id, photo_id), 
	FOREIGN KEY (photo_album_id) REFERENCES photo_albums(id) ON DELETE CASCADE,
	FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE,
	FOREIGN KEY (user_commented_id) REFERENCES users(id) ON DELETE CASCADE
);


-- table for wall content
DROP TABLE IF EXISTS wall;
CREATE TABLE wall (
	id SERIAL,
	user_posted_id BIGINT UNSIGNED NOT NULL,
	content_id BIGINT UNSIGNED NOT NULL COMMENT 'some text or text with media note',
	note TEXT COMMENT 'some additional text to posted content',
	created_at DATETIME DEFAULT NOW() COMMENT 'time when note on wall was left',
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP COMMENT 'time when user who left note last time corrected it',
    --  If an ENUM column is declared NOT NULL, its default value is the first element of the list of permitted values (manual 11.3.5)
    is_pinned ENUM ('no', 'yes') NOT NULL COMMENT 'shows is the post have to be on top of the wall constantly',
    is_comments_allowed ENUM ('no', 'yes') NOT NULL COMMENT 'shows if the post could be commented or not',
    FOREIGN KEY (user_posted_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES media(id) ON DELETE CASCADE
);



