-- Migration 00044: Rating & Review System

-- Create review_tags table
CREATE TABLE review_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('buyer', 'seller', 'general')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE review_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access to review_tags" ON review_tags FOR SELECT USING (true);
CREATE POLICY "Admin full access to review_tags" ON review_tags FOR ALL USING (
    EXISTS (SELECT 1 FROM admin_roles WHERE user_id = auth.uid())
);

-- Insert some default tags
INSERT INTO review_tags (name, type) VALUES
('Fast Communicator', 'seller'),
('Accurate Description', 'seller'),
('Friendly', 'seller'),
('Punctual', 'seller'),
('Quick Payment', 'buyer'),
('Easy to work with', 'buyer'),
('Friendly', 'buyer'),
('Punctual', 'buyer');

-- Create user_reviews table
CREATE TABLE user_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    target_user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('buyer', 'seller')), -- Role of the target user
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Ensure one review per order per reviewer
    UNIQUE(order_id, reviewer_id)
);

ALTER TABLE user_reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access to user_reviews" ON user_reviews FOR SELECT USING (true);
CREATE POLICY "Users can insert their own reviews" ON user_reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- Create user_review_tag_links table
CREATE TABLE user_review_tag_links (
    review_id UUID NOT NULL REFERENCES user_reviews(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES review_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (review_id, tag_id)
);

ALTER TABLE user_review_tag_links ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access to user_review_tag_links" ON user_review_tag_links FOR SELECT USING (true);
CREATE POLICY "Users can insert tags for their reviews" ON user_review_tag_links FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM user_reviews WHERE id = review_id AND reviewer_id = auth.uid())
);

-- Update user_profiles table with cached rating fields
ALTER TABLE user_profiles 
    ADD COLUMN buyer_rating NUMERIC(3,2) NOT NULL DEFAULT 0.00,
    ADD COLUMN buyer_rating_count INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN seller_rating NUMERIC(3,2) NOT NULL DEFAULT 0.00,
    ADD COLUMN seller_rating_count INTEGER NOT NULL DEFAULT 0;

-- Function to recalculate rating when a review is added
CREATE OR REPLACE FUNCTION update_user_rating_cache()
RETURNS TRIGGER AS $$
DECLARE
    t_id UUID;
    t_role TEXT;
    new_avg NUMERIC(3,2);
    new_count INTEGER;
BEGIN
    IF TG_OP = 'DELETE' THEN
        t_id := OLD.target_user_id;
        t_role := OLD.role;
    ELSE
        t_id := NEW.target_user_id;
        t_role := NEW.role;
    END IF;

    SELECT COALESCE(AVG(rating), 0.00), COUNT(*)
    INTO new_avg, new_count
    FROM user_reviews
    WHERE target_user_id = t_id AND role = t_role;

    IF t_role = 'buyer' THEN
        UPDATE user_profiles
        SET buyer_rating = new_avg, buyer_rating_count = new_count
        WHERE id = t_id;
    ELSIF t_role = 'seller' THEN
        UPDATE user_profiles
        SET seller_rating = new_avg, seller_rating_count = new_count
        WHERE id = t_id;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_user_review_added
    AFTER INSERT OR UPDATE OR DELETE ON user_reviews
    FOR EACH ROW EXECUTE FUNCTION update_user_rating_cache();

