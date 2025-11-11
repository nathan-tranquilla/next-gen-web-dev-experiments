import React, { useState, useEffect } from 'react';
import { useParams, useSearchParams, Link } from 'react-router-dom';

const UserPage = () => {
  const { userid } = useParams();
  const [searchParams] = useSearchParams();
  const filter = searchParams.get('filter');
  
  interface User {
    id: string | undefined;
    name: string;
    email: string;
    bio: string;
  }
  
  const [user, setUser] = useState<User | null>(null);
  const [content, setContent] = useState<Array<{ id: number; type: string; title?: string; content: string; postTitle?: string }>>([]);

  useEffect(() => {
    // Mock user data - replace with your API call
    const mockUser = {
      id: userid,
      name: `User ${userid}`,
      email: `user${userid}@example.com`,
      bio: `This is the bio for user ${userid}`
    };
    setUser(mockUser);

    // Mock content based on filter
    let mockContent: Array<{ id: number; type: string; title?: string; content: string; postTitle?: string }> = [];
    if (filter === 'posts') {
      mockContent = [
        { id: 1, type: 'post', title: 'My First Post', content: 'This is my first post content...' },
        { id: 2, type: 'post', title: 'Another Post', content: 'This is another post content...' },
      ];
    } else if (filter === 'comments') {
      mockContent = [
        { id: 1, type: 'comment', content: 'Great article!', postTitle: 'How to Code' },
        { id: 2, type: 'comment', content: 'Thanks for sharing!', postTitle: 'React Tips' },
      ];
    }
    setContent(mockContent);
  }, [userid, filter]);

  if (!user) {
    return <div>Loading...</div>;
  }

  return (
    <div className="max-w-4xl mx-auto p-6 bg-white">
      <Link 
        to="/users" 
        className="inline-flex items-center text-blue-600 hover:text-blue-800 transition-colors mb-6 font-medium"
      >
        ← Back to Users
      </Link>
      
      {/* User Profile Card */}
      <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-6 mb-8 border border-gray-200 shadow-sm">
        <h1 className="text-3xl font-bold text-gray-900 mb-4">{user.name}</h1>
        <div className="space-y-2">
          <p className="text-gray-600">
            <span className="font-semibold text-gray-800">Email:</span> {user.email}
          </p>
          <p className="text-gray-600">
            <span className="font-semibold text-gray-800">Bio:</span> {user.bio}
          </p>
        </div>
      </div>

      {/* Navigation Tabs */}
      <div className="flex space-x-1 bg-gray-100 p-1 rounded-lg mb-8">
        <Link 
          to={`/users/${userid}`}
          className={`px-6 py-2 rounded-md font-medium transition-colors ${
            !filter 
              ? 'bg-white text-blue-600 shadow-sm' 
              : 'text-gray-600 hover:text-gray-800 hover:bg-gray-200'
          }`}
        >
          Profile
        </Link>
        <Link 
          to={`/users/${userid}?filter=posts`}
          className={`px-6 py-2 rounded-md font-medium transition-colors ${
            filter === 'posts' 
              ? 'bg-white text-blue-600 shadow-sm' 
              : 'text-gray-600 hover:text-gray-800 hover:bg-gray-200'
          }`}
        >
          Posts
        </Link>
        <Link 
          to={`/users/${userid}?filter=comments`}
          className={`px-6 py-2 rounded-md font-medium transition-colors ${
            filter === 'comments' 
              ? 'bg-white text-blue-600 shadow-sm' 
              : 'text-gray-600 hover:text-gray-800 hover:bg-gray-200'
          }`}
        >
          Comments
        </Link>
      </div>

      {/* Content Section */}
      {filter && (
        <div>
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            {filter.charAt(0).toUpperCase() + filter.slice(1)}
          </h2>
          {content.length === 0 ? (
            <div className="text-center py-12 bg-gray-50 rounded-lg">
              <p className="text-gray-500">No {filter} found.</p>
            </div>
          ) : (
            <div className="grid gap-4">
              {content.map(item => (
                <div key={item.id} className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm hover:shadow-md transition-shadow">
                  {item.type === 'post' ? (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900 mb-2">{item.title}</h4>
                      <p className="text-gray-600 leading-relaxed">{item.content}</p>
                    </div>
                  ) : (
                    <div>
                      <p className="text-gray-700 mb-2 leading-relaxed">{item.content}</p>
                      <small className="text-gray-500 font-medium">On: <span className="text-blue-600">{item.postTitle}</span></small>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default UserPage;