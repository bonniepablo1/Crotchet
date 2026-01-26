-- Seed Data for Crotchet Dating App
-- This script creates test users, profiles, likes, matches, and messages for development and testing

-- Note: This seed data is for development/testing purposes only
-- In production, users are created through the Supabase Auth API

-- Clear existing test data (careful with this in production!)
-- TRUNCATE likes, matches, conversations, messages CASCADE;

-- Insert test profiles (assuming auth.users already exist with these IDs)
-- In a real scenario, you'd create users via Supabase Auth API first

-- Test User 1: Alice
INSERT INTO profiles (id, username, full_name, date_of_birth, gender, looking_for, bio, location, nationality, interests, photos, verified_email, is_active)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'alice_wonder', 'Alice Wonder', '1995-03-15', 'woman', ARRAY['man'], 'Adventure seeker and coffee enthusiast. Love hiking and trying new restaurants!', 'New York, NY', 'US', ARRAY['hiking', 'coffee', 'photography', 'travel'], ARRAY['{"url": "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg", "order": 1}'::jsonb], true, true)
ON CONFLICT (id) DO NOTHING;

-- Test User 2: Bob
INSERT INTO profiles (id, username, full_name, date_of_birth, gender, looking_for, bio, location, nationality, interests, photos, verified_email, is_active)
VALUES
  ('00000000-0000-0000-0000-000000000002', 'bob_builder', 'Bob Builder', '1992-07-22', 'man', ARRAY['woman'], 'Software engineer by day, chef by night. Looking for someone to share good food and laughs with.', 'San Francisco, CA', 'US', ARRAY['cooking', 'technology', 'music', 'fitness'], ARRAY['{"url": "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg", "order": 1}'::jsonb], true, true)
ON CONFLICT (id) DO NOTHING;

-- Test User 3: Carol
INSERT INTO profiles (id, username, full_name, date_of_birth, gender, looking_for, bio, location, nationality, interests, photos, verified_email, is_active)
VALUES
  ('00000000-0000-0000-0000-000000000003', 'carol_creative', 'Carol Creative', '1998-11-08', 'woman', ARRAY['woman', 'man'], 'Artist and designer. I paint, sketch, and create. Let''s explore the world together!', 'Los Angeles, CA', 'US', ARRAY['art', 'design', 'museums', 'yoga'], ARRAY['{"url": "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg", "order": 1}'::jsonb], true, true)
ON CONFLICT (id) DO NOTHING;

-- Test User 4: David
INSERT INTO profiles (id, username, full_name, date_of_birth, gender, looking_for, bio, location, nationality, interests, photos, verified_email, is_active)
VALUES
  ('00000000-0000-0000-0000-000000000004', 'david_dash', 'David Dash', '1990-05-30', 'man', ARRAY['woman'], 'Marathon runner and book lover. Always up for a good conversation over coffee.', 'Boston, MA', 'US', ARRAY['running', 'reading', 'coffee', 'podcasts'], ARRAY['{"url": "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg", "order": 1}'::jsonb], true, true)
ON CONFLICT (id) DO NOTHING;

-- Create some likes
INSERT INTO likes (liker_id, likee_id, created_at)
VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '2 days'),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '1 day'),  -- This creates a match!
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', NOW() - INTERVAL '3 hours'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004', NOW() - INTERVAL '5 hours'),
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', NOW() - INTERVAL '4 hours')  -- This creates another match!
ON CONFLICT (liker_id, likee_id) DO NOTHING;

-- Matches and conversations are created automatically via triggers

-- Wait a moment for triggers to complete, then insert messages
-- Get the conversation IDs first
DO $$
DECLARE
  v_conv_id_1 uuid;
  v_conv_id_2 uuid;
BEGIN
  -- Get conversation between Alice and Bob
  SELECT c.id INTO v_conv_id_1
  FROM conversations c
  JOIN matches m ON c.match_id = m.id
  WHERE (m.user1_id = '00000000-0000-0000-0000-000000000001' AND m.user2_id = '00000000-0000-0000-0000-000000000002')
     OR (m.user1_id = '00000000-0000-0000-0000-000000000002' AND m.user2_id = '00000000-0000-0000-0000-000000000001');

  -- Get conversation between Carol and David
  SELECT c.id INTO v_conv_id_2
  FROM conversations c
  JOIN matches m ON c.match_id = m.id
  WHERE (m.user1_id = '00000000-0000-0000-0000-000000000003' AND m.user2_id = '00000000-0000-0000-0000-000000000004')
     OR (m.user1_id = '00000000-0000-0000-0000-000000000004' AND m.user2_id = '00000000-0000-0000-0000-000000000003');

  -- Insert messages for conversation 1 (Alice and Bob)
  IF v_conv_id_1 IS NOT NULL THEN
    INSERT INTO messages (conversation_id, sender_id, content, read, created_at)
    VALUES
      (v_conv_id_1, '00000000-0000-0000-0000-000000000001', 'Hey! Nice to match with you!', true, NOW() - INTERVAL '1 day' + INTERVAL '10 minutes'),
      (v_conv_id_1, '00000000-0000-0000-0000-000000000002', 'Hi Alice! Thanks, you too! Love your profile pics.', true, NOW() - INTERVAL '1 day' + INTERVAL '25 minutes'),
      (v_conv_id_1, '00000000-0000-0000-0000-000000000001', 'Thanks! I saw you''re into cooking. What''s your specialty?', true, NOW() - INTERVAL '1 day' + INTERVAL '30 minutes'),
      (v_conv_id_1, '00000000-0000-0000-0000-000000000002', 'I make a mean pasta carbonara! Do you enjoy cooking too?', true, NOW() - INTERVAL '1 day' + INTERVAL '35 minutes'),
      (v_conv_id_1, '00000000-0000-0000-0000-000000000001', 'I try! Though my skills are more amateur. Would love to learn from you sometime!', true, NOW() - INTERVAL '1 day' + INTERVAL '42 minutes'),
      (v_conv_id_1, '00000000-0000-0000-0000-000000000002', 'That sounds great! Maybe we could grab coffee first and talk food?', false, NOW() - INTERVAL '23 hours');
  END IF;

  -- Insert messages for conversation 2 (Carol and David)
  IF v_conv_id_2 IS NOT NULL THEN
    INSERT INTO messages (conversation_id, sender_id, content, read, created_at)
    VALUES
      (v_conv_id_2, '00000000-0000-0000-0000-000000000003', 'Hi David! Fellow creative here. I see you''re into running!', true, NOW() - INTERVAL '4 hours' + INTERVAL '5 minutes'),
      (v_conv_id_2, '00000000-0000-0000-0000-000000000004', 'Hey Carol! Yes, I love running. Helps clear my mind. What kind of art do you do?', true, NOW() - INTERVAL '3 hours' + INTERVAL '50 minutes'),
      (v_conv_id_2, '00000000-0000-0000-0000-000000000003', 'Mostly painting and digital design. Running sounds amazing though, I should try it!', true, NOW() - INTERVAL '3 hours' + INTERVAL '40 minutes'),
      (v_conv_id_2, '00000000-0000-0000-0000-000000000004', 'I''d be happy to go on an easy jog with you if you''d like! We could grab smoothies after.', false, NOW() - INTERVAL '3 hours' + INTERVAL '20 minutes');
  END IF;
END $$;

-- Verify the seed data
SELECT 'Profiles:' as check_type, COUNT(*) as count FROM profiles
UNION ALL
SELECT 'Likes:', COUNT(*) FROM likes
UNION ALL
SELECT 'Matches:', COUNT(*) FROM matches
UNION ALL
SELECT 'Conversations:', COUNT(*) FROM conversations
UNION ALL
SELECT 'Messages:', COUNT(*) FROM messages;
