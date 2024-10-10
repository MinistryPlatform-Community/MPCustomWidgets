
export class ApiService {
    static async getData(endpoint, userToken) {
        var headers = {};

        if (userToken)
        {
            headers.Authorization = userToken;
        }

        const requestOptions = {
            method: "GET",
            headers: headers
        };

        try {
            const response = await fetch(`${endpoint}`, requestOptions);

            if (!response.ok) {
                const errorResponse = await response.json();
                console.error(errorResponse.error, errorResponse.details);
                return;
            }
    
            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Network or CORS error:', error.message);
        }

    }
}